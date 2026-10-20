<?php
namespace Hestia\WebApp\Installers\NodeJS;

/**
 * HestiaCP Node.js & PM2 Quick Install App
 * Author: pochii-dev (https://github.com/pochii-dev)
 * Supports dynamic ports (e.g. 3041, 3000, 8080), PM2 cluster and Nginx proxy
 */

use Hestia\System\Util;
use \Hestia\WebApp\Installers\BaseSetup as BaseSetup;

class NodeJSSetup extends BaseSetup {
    protected $appInfo = [
        'name' => 'Node.js & PM2',
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
                'label' => 'Application Name (PM2 process name)',
                'value' => 'node-app'
            ],
            'app_port' => [
                'type' => 'text',
                'label' => 'Port (Local Port, e.g. 3041, 3000, 8080)',
                'value' => '3000'
            ],
            'startup_file' => [
                'type' => 'text',
                'label' => 'Startup Entry File (e.g. app.js, index.js, server.js)',
                'value' => 'app.js'
            ],
            'app_template' => [
                'type' => 'select',
                'label' => 'Starter Template / Boilerplate',
                'options' => [
                    'express' => 'Express.js Starter (API + Web)',
                    'fastify' => 'Fastify Starter (High Performance)',
                    'minimal' => 'Native Node.js HTTP Server (Zero Dependencies)',
                    'blank'   => 'Blank (Keep existing files or deploy custom code)'
                ],
                'value' => 'express'
            ],
            'node_env' => [
                'type' => 'select',
                'label' => 'Environment (NODE_ENV)',
                'options' => [
                    'production' => 'Production',
                    'development' => 'Development'
                ],
                'value' => 'production'
            ],
            'pm2_instances' => [
                'type' => 'select',
                'label' => 'PM2 Cluster Instances',
                'options' => [
                    '1' => '1 Instance (Single Process)',
                    '2' => '2 Instances (Cluster Mode)',
                    '4' => '4 Instances (Cluster Mode)',
                    'max' => 'max (All Available CPU Cores)'
                ],
                'value' => '1'
            ],
            'auto_start' => [
                'type' => 'select',
                'label' => 'Start PM2 Process Immediately',
                'options' => [
                    'yes' => 'Yes (Start & Save to Startup)',
                    'no' => 'No (Configure files only)'
                ],
                'value' => 'yes'
            ]
        ],
        'database' => false,
        'server' => [
            'nginx' => [
                'template' => 'nodejs'
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
        $user = $this->appcontext->user();
        $domain = $this->appcontext->domain();

        if (empty($user) || empty($domain)) {
            throw new \Exception("User and domain context are required for Node.js installation.");
        }

        // Sanitize options
        $appName = !empty($options['app_name']) ? preg_replace('/[^a-zA-Z0-9_\-]/', '', $options['app_name']) : 'node-' . str_replace('.', '-', $domain);
        $appPort = !empty($options['app_port']) ? intval($options['app_port']) : 3000;
        $startupFile = !empty($options['startup_file']) ? basename($options['startup_file']) : 'app.js';
        $appTemplate = !empty($options['app_template']) ? $options['app_template'] : 'express';
        $nodeEnv = (!empty($options['node_env']) && $options['node_env'] === 'development') ? 'development' : 'production';
        $pm2Instances = !empty($options['pm2_instances']) ? $options['pm2_instances'] : '1';
        $autoStart = (!empty($options['auto_start']) && $options['auto_start'] === 'no') ? 'no' : 'yes';

        // Check if v-add-web-domain-nodejs script exists in HestiaCP bin
        $cliScript = '/usr/local/hestia/bin/v-add-web-domain-nodejs';
        if (!file_exists($cliScript)) {
            throw new \Exception("Required CLI executable $cliScript is missing. Please reinstall hestia-nodejs module.");
        }

        $cmd = sprintf(
            '%s %s %s %d %s %s %s %s %s %s',
            escapeshellcmd($cliScript),
            escapeshellarg($user),
            escapeshellarg($domain),
            $appPort,
            escapeshellarg($appName),
            escapeshellarg($startupFile),
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
            throw new \Exception("Failed to install Node.js app: " . $errorMsg);
        }

        return true;
    }
}
