# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class addon_scriptworker {
    include addon_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include tweaks::scriptworkerlogrotate

    python35::virtualenv {
        $addon_scriptworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $addon_scriptworker::settings::user,
            group    => $addon_scriptworker::settings::group,
            mode     => 700,
            packages => [
                'PyYAML==3.12',
                'addonscript==0.3',
                'aiohttp==2.3.9',
                'arrow==0.12.1',
                'async_timeout==1.4.0',
                'certifi==2018.1.18',
                'chardet==3.0.4',
                'defusedxml==0.5.0',
                'dictdiffer==0.7.0',
                'ecdsa==0.13',
                'frozendict==1.2',
                'future==0.16.0',
                'idna==2.6',
                'json-e==2.5.0',
                'jsonschema==2.6.0',
                'mohawk==0.3.4',
                'multidict==4.0.0',
                'pexpect==4.3.1',
                'ptyprocess==0.5.2',
                'pycryptodome==3.5.1',
                'python-dateutil==2.6.1',
                'python-gnupg==0.4.1',
                'python-jose==2.0.2',
                'redo==1.6',
                'requests==2.18.4',
                'scriptworker==10.2.0',
                'six==1.10.0',
                'slugid==1.0.7',
                'taskcluster==2.1.3',
                'urllib3==1.22',
                'virtualenv==15.1.0',
                'yarl==1.0.0',
            ];
    }

    scriptworker::instance {
        $addon_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $addon_scriptworker::settings::root,
            work_dir                 => $addon_scriptworker::settings::work_dir,

            task_script              => $addon_scriptworker::settings::task_script,

            username                 => $addon_scriptworker::settings::user,
            group                    => $addon_scriptworker::settings::group,

            taskcluster_client_id    => $addon_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $addon_scriptworker::settings::taskcluster_access_token,
            worker_group             => $addon_scriptworker::settings::worker_group,
            worker_type              => $addon_scriptworker::settings::worker_type,

            cot_job_type             => 'shipit',

            sign_chain_of_trust      => $addon_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $addon_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $addon_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $addon_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $addon_scriptworker::settings::user,
        group       => $addon_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $addon_scriptworker::settings::script_config_content
    file {
        $addon_scriptworker::settings::script_config:
            require => Python35::Virtualenv[$addon_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }
}