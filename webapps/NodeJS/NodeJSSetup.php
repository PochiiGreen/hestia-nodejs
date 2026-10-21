<?php
namespace Hestia\WebApp\Installers\NodeJS;

/**
 * HestiaCP Node.js & PM2 Quick Install App
 * Author: pochii-dev / PochiiGreen (https://github.com/PochiiGreen)
 * Compatible with Hestia Control Panel v1.10.x & v1.10.5+
 */

use Hestia\System\Util;
use Hestia\WebApp\Installers\BaseSetup as BaseSetup;

class NodeJSSetup extends BaseSetup {
    protected $appInfo = [
        'name' => 'NodeJS',
        'group' => 'framework',
        'enabled' => true,
        'version' => 'latest',
        'thumbnail' => 'nodejs.png'
    ];

    protected $appname = 'nodejs';

    protected $config = [
        'form' => [
            'app_name' => [
                'type' => 'text',
                'value' => 'my-node-app'
            ],
            'app_port' => [
                'type' => 'text',
                'value' => '3000'
            ],
            'startup_file' => [
                'type' => 'text',
                'value' => 'app.js'
            ],
            'package_manager' => [
                'type' => 'select',
                'options' => ['pnpm', 'npm', 'yarn'],
                'value' => 'pnpm'
            ],
            'app_template' => [
                'type' => 'select',
                'options' => ['express', 'fastify', 'minimal', 'blank'],
                'value' => 'express'
            ],
            'node_env' => [
                'type' => 'select',
                'options' => ['production', 'development'],
                'value' => 'production'
            ],
            'pm2_instances' => [
                'type' => 'select',
                'options' => ['1', '2', '4', 'max'],
                'value' => '1'
            ],
            'auto_start' => [
                'type' => 'select',
                'options' => ['yes', 'no'],
                'value' => 'yes'
            ]
        ],
        'database' => false,
        'resources' => [
            'archive' => [
                'src' => ''
            ]
        ],
        'server' => [
            'nginx' => [
                'template' => 'nodejs'
            ],
            'apache2' => [
                'template' => 'default'
            ],
            'php' => [
                'supported' => [
                    '7.4', '8.0', '8.1', '8.2', '8.3', '8.4', '8.5'
                ]
            ]
        ]
    ];

    /**
     * Install execution method called by HestiaCP WebApp installer
     *
     * @param array|null $options
     * @return bool
     * @throws \Exception
     */
    public function install(array $options = null) {
        $domain = !empty($this->domain) ? $this->domain : (method_exists($this->appcontext, 'domain') ? $this->appcontext->domain() : '');
        $user = method_exists($this->appcontext, 'user') ? $this->appcontext->user() : '';

        // Fallback user resolution if needed
        if (empty($user) && !empty($domain)) {
            $userLookup = exec("grep -l \"DOMAIN='$domain'\" /usr/local/hestia/data/users/*/web.conf 2>/dev/null | cut -d'/' -f7");
            if (!empty($userLookup)) {
                $user = trim($userLookup);
            }
        }

        if (empty($user) || empty($domain)) {
            throw new \Exception("No se pudo resolver el contexto de usuario o dominio para la instalación de Node.js.");
        }

        // Extract and sanitize options
        $appName = !empty($options['app_name']) ? preg_replace('/[^a-zA-Z0-9_\-]/', '', $options['app_name']) : 'node-' . str_replace('.', '-', $domain);
        $appPort = !empty($options['app_port']) ? intval($options['app_port']) : 3000;
        $startupFile = !empty($options['startup_file']) ? basename($options['startup_file']) : 'app.js';
        $pkgMgr = (!empty($options['package_manager']) && in_array($options['package_manager'], ['pnpm', 'npm', 'yarn'])) ? $options['package_manager'] : 'pnpm';
        $appTemplate = (!empty($options['app_template']) && in_array($options['app_template'], ['express', 'fastify', 'minimal', 'blank'])) ? $options['app_template'] : 'express';
        $nodeEnv = (!empty($options['node_env']) && $options['node_env'] === 'development') ? 'development' : 'production';
        $pm2Instances = (!empty($options['pm2_instances']) && in_array($options['pm2_instances'], ['1', '2', '4', 'max'])) ? $options['pm2_instances'] : '1';
        $autoStart = (!empty($options['auto_start']) && $options['auto_start'] === 'no') ? 'no' : 'yes';

        $cliScript = '/usr/local/hestia/bin/v-add-web-domain-nodejs';
        if (!file_exists($cliScript)) {
            throw new \Exception("El comando de instalación $cliScript no se encuentra disponible.");
        }

        $cmd = sprintf(
            '%s %s %s %d %s %s %s %s %s %s %s',
            escapeshellcmd($cliScript),
            escapeshellarg($user),
            escapeshellarg($domain),
            $appPort,
            escapeshellarg($appName),
            escapeshellarg($startupFile),
            escapeshellarg($pkgMgr),
            escapeshellarg($appTemplate),
            escapeshellarg($nodeEnv),
            escapeshellarg($pm2Instances),
            escapeshellarg($autoStart)
        );

        $output = [];
        $returnCode = 0;
        exec($cmd . ' 2>&1', $output, $returnCode);

        if ($returnCode !== 0) {
            $errorMsg = implode("\n", $output);
            throw new \Exception("Fallo al configurar la aplicación Node.js: " . $errorMsg);
        }

        return true;
    }
}
