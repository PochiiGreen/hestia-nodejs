<?php

declare(strict_types=1);

namespace Hestia\WebApp\Installers\NodeJS;

use Hestia\WebApp\BaseSetup;
use Hestia\WebApp\InstallationTarget\InstallationTarget;
use Symfony\Component\Process\Process;
use RuntimeException;

// Backward-compatibility alias if BaseSetup is located in older namespace
if (!class_exists('Hestia\WebApp\BaseSetup', false) && class_exists('Hestia\WebApp\Installers\BaseSetup', false)) {
    class_alias('Hestia\WebApp\Installers\BaseSetup', 'Hestia\WebApp\BaseSetup');
}

/**
 * HestiaCP Node.js, PNPM & PM2 Quick Install App
 * Author: pochii-dev / PochiiGreen (https://github.com/PochiiGreen)
 * Fully compatible with Hestia Control Panel v1.10.x & v1.10.5+
 */
class NodeJSSetup extends BaseSetup
{
    protected array $info = [
        'name' => 'NodeJS',
        'group' => 'framework',
        'version' => 'latest',
        'thumbnail' => 'nodejs.png',
    ];

    protected array $config = [
        'form' => [
            'app_name' => [
                'type' => 'text',
                'label' => 'App Name / PM2 Process Name',
                'value' => 'my-node-app',
            ],
            'app_port' => [
                'type' => 'text',
                'label' => 'Port (e.g. 3000, 3041, 8080)',
                'value' => '3000',
            ],
            'startup_file' => [
                'type' => 'text',
                'label' => 'Entry Script',
                'value' => 'app.js',
            ],
            'package_manager' => [
                'type' => 'select',
                'label' => 'Package Manager',
                'value' => 'pnpm',
                'options' => [
                    'pnpm' => 'pnpm (Recommended - Fast & Disk-efficient)',
                    'npm'  => 'npm (Default Node Package Manager)',
                    'yarn' => 'yarn (Classic)',
                ],
            ],
            'app_template' => [
                'type' => 'select',
                'label' => 'Starter Template',
                'value' => 'express',
                'options' => [
                    'express' => 'Express.js (REST API + Health Check + Logger)',
                    'fastify' => 'Fastify (High Performance JSON API)',
                    'minimal' => 'Minimal (Native HTTP, Zero-dependency)',
                    'blank'   => 'Blank (Empty project / Bring your own code)',
                ],
            ],
            'node_env' => [
                'type' => 'select',
                'label' => 'Environment (NODE_ENV)',
                'value' => 'production',
                'options' => [
                    'production'  => 'production',
                    'development' => 'development',
                ],
            ],
            'pm2_instances' => [
                'type' => 'select',
                'label' => 'PM2 Cluster Instances',
                'value' => '1',
                'options' => [
                    '1'   => '1 Instance (Fork mode)',
                    '2'   => '2 Instances (Cluster mode)',
                    '4'   => '4 Instances (Cluster mode)',
                    'max' => 'max (Cluster across all CPU cores)',
                ],
            ],
            'auto_start' => [
                'type' => 'select',
                'label' => 'Auto Start with PM2?',
                'value' => 'yes',
                'options' => [
                    'yes' => 'Yes (Start via PM2 & save systemd persistence)',
                    'no'  => 'No (Generate files and proxy template only)',
                ],
            ],
        ],
        'database' => false,
        'resources' => [],
        'server' => [
            'nginx' => [
                'template' => 'nodejs',
            ],
            'php' => [
                'supported' => ['7.4', '8.0', '8.1', '8.2', '8.3', '8.4', '8.5'],
            ],
        ],
    ];

    /**
     * Executes the Node.js application scaffolding and PM2 integration
     */
    protected function setupApplication(InstallationTarget $target, array $options): void
    {
        $domain = $target->domain->domainName;

        // Resolve user
        $user = '';
        if (method_exists($this->appcontext, 'user')) {
            $user = (string)$this->appcontext->user();
        }
        if (empty($user) && !empty($_SESSION['user'])) {
            $user = (string)$_SESSION['user'];
        }
        if (empty($user) && !empty($target->domain->domainPath)) {
            $parts = explode('/', trim($target->domain->domainPath, '/'));
            if (isset($parts[1])) {
                $user = $parts[1];
            }
        }
        if (empty($user)) {
            $userLookup = exec(sprintf("grep -l \"DOMAIN='%s'\" /usr/local/hestia/data/users/*/web.conf 2>/dev/null | cut -d'/' -f7", escapeshellcmd($domain)));
            if (!empty($userLookup)) {
                $user = trim($userLookup);
            }
        }
        if (empty($user)) {
            $user = 'admin';
        }

        // Options sanitization
        $appName = !empty($options['app_name']) ? preg_replace('/[^a-zA-Z0-9_\-]/', '', (string)$options['app_name']) : 'node-' . str_replace('.', '-', $domain);
        if (empty($appName)) {
            $appName = 'node-' . str_replace('.', '-', $domain);
        }

        $appPort = !empty($options['app_port']) ? intval($options['app_port']) : 3000;
        if ($appPort <= 0 || $appPort > 65535) {
            $appPort = 3000;
        }

        $startupFile = !empty($options['startup_file']) ? basename((string)$options['startup_file']) : 'app.js';
        $pkgMgr = (!empty($options['package_manager']) && in_array($options['package_manager'], ['pnpm', 'npm', 'yarn'], true)) ? $options['package_manager'] : 'pnpm';
        $appTemplate = (!empty($options['app_template']) && in_array($options['app_template'], ['express', 'fastify', 'minimal', 'blank'], true)) ? $options['app_template'] : 'express';
        $nodeEnv = (!empty($options['node_env']) && $options['node_env'] === 'development') ? 'development' : 'production';
        $pm2Instances = (!empty($options['pm2_instances']) && in_array((string)$options['pm2_instances'], ['1', '2', '4', 'max'], true)) ? (string)$options['pm2_instances'] : '1';
        $autoStart = (!empty($options['auto_start']) && $options['auto_start'] === 'no') ? 'no' : 'yes';

        $cliScript = '/usr/local/hestia/bin/v-add-web-domain-nodejs';
        if (!file_exists($cliScript)) {
            throw new RuntimeException("El script CLI $cliScript no se encuentra instalado en el sistema.");
        }

        $cmd = [
            '/usr/bin/sudo',
            $cliScript,
            $user,
            $domain,
            (string)$appPort,
            $appName,
            $startupFile,
            $pkgMgr,
            $appTemplate,
            $nodeEnv,
            $pm2Instances,
            $autoStart,
        ];

        if (class_exists('Symfony\Component\Process\Process')) {
            $process = new Process($cmd);
            $process->setTimeout(300);
            $process->run();

            if (!$process->isSuccessful()) {
                throw new RuntimeException("Error al configurar la app Node.js: " . $process->getErrorOutput() . " " . $process->getOutput());
            }
        } else {
            $escapedCmd = implode(' ', array_map('escapeshellarg', $cmd));
            $output = [];
            $returnCode = 0;
            exec($escapedCmd . ' 2>&1', $output, $returnCode);

            if ($returnCode !== 0) {
                throw new RuntimeException("Error al configurar la app Node.js: " . implode("\n", $output));
            }
        }
    }
}
