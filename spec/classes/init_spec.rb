require 'spec_helper'

describe 'consul_alerts' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it do
        is_expected.to contain_archive('consul-alerts-0.5.0-linux-amd64.tar').with(
          path:         '/tmp/consul-alerts-0.5.0-linux-amd64.tar',
          extract:      true,
          extract_path: '/usr/local/bin',
          source:       'https://github.com/AcalephStorage/consul-alerts/releases/download/v0.5.0/consul-alerts-0.5.0-linux-amd64.tar',
          creates:      '/usr/local/bin/consul-alerts',
          cleanup:      true,
          notify:       'Service[consul-alerts.service]',
        )
      end
      it do
        is_expected.to contain_file('/etc/systemd/system/consul-alerts.service').with_content(
          %r{ExecStart=/usr/local/bin/consul-alerts},
        )
      end
      it do
        is_expected.to contain_service('consul-alerts.service').with(
          ensure: true,
          enable: true,
        )
      end
    end
  end
end
