require 'spec_helper'

describe 'rabbitmq::config' do

  let(:cluster_disk_nodes)       { false }
  let(:cluster_node_type)        { 'disc' }
  let(:cluster_nodes)            { [] }
  let(:config)                   { 'rabbitmq/rabbitmq.config.erb' }
  let(:config_cluster)           { false }
  let(:config_mirrored_queues)   { false }
  let(:config_path)              { '/etc/rabbitmq/rabbitmq.conf' }
  let(:config_stomp)             { false }
  let(:delete_guest_user)        { false }
  let(:env_config)               { 'rabbitmq/rabbitmq-env.conf.erb' }
  let(:env_config_path)          { '/etc/rabbitmq/rabbitmq-env.conf' }
  let(:erlang_cookie)            { 'EOKOWXQREETZSHFNTPEY' }
  let(:node_ip_address)          { 'UNSET' }
  let(:plugin_dir)               { "/usr/lib/rabbitmq/lib/rabbitmq_server-${version}" }
  let(:port)                     { '5672' }
  let(:service_name)             { 'rabbitmq-server' }
  let(:stomp_port)               { '6163' }
  let(:wipe_db_on_cookie_change) { false }

  ['Debian', 'RedHat'].each do |distro|
    context "on #{distro}" do
      let(:facts) {{ :osfamily => distro, :rabbitmq_erlang_cookie => 'EOKOWXQREETZSHFNTPEY' }}
  let(:cluster_disk_nodes)       { false }
  let(:cluster_node_type)        { 'disc' }
  let(:cluster_nodes)            { [] }
  let(:config)                   { 'rabbitmq/rabbitmq.config.erb' }
  let(:config_cluster)           { false }
  let(:config_mirrored_queues)   { false }
  let(:config_path)              { '/etc/rabbitmq/rabbitmq.conf' }
  let(:config_stomp)             { false }
  let(:delete_guest_user)        { false }
  let(:env_config)               { 'rabbitmq/rabbitmq-env.conf.erb' }
  let(:env_config_path)          { '/etc/rabbitmq/rabbitmq-env.conf' }
  let(:erlang_cookie)            { 'EOKOWXQREETZSHFNTPEY' }
  let(:node_ip_address)          { 'UNSET' }
  let(:plugin_dir)               { "/usr/lib/rabbitmq/lib/rabbitmq_server-${version}" }
  let(:port)                     { '5672' }
  let(:service_name)             { 'rabbitmq-server' }
  let(:stomp_port)               { '6163' }
  let(:wipe_db_on_cookie_change) { false }

      context 'deprecated parameters' do
        describe 'cluster_disk_nodes' do
          let(:cluster_disk_nodes) {['node1', 'node2']}

          it { should contain_notify('cluster_disk_nodes') }
        end
      end

      describe 'manages configuration directory correctly' do
        it { should contain_file('/etc/rabbitmq').with(
          'ensure' => 'directory'
        )}
      end

      describe 'manages configuration file correctly' do
        it { should contain_file('rabbitmq.config') }
      end

      context 'configures config_cluster' do
        let(:facts) {{ :osfamily => distro, :rabbitmq_erlang_cookie => 'ORIGINAL' }}
        let(:config_cluster)           { true }
        let(:cluster_nodes)            { ['hare-1', 'hare-2'] }
        let(:cluster_node_type)        { 'ram' }
        let(:erlang_cookie)            { 'TESTCOOKIE' }
        let(:wipe_db_on_cookie_change) { false }

        describe 'with defaults' do
          it 'fails' do
            expect{subject}.to raise_error(/^ERROR: The current erlang cookie is ORIGINAL/)
          end
        end

        describe 'with wipe_db_on_cookie_change set' do
          let(:config_cluster)           { true }
          let(:cluster_nodes)            { ['hare-1', 'hare-2'] }
          let(:cluster_node_type)        { 'ram' }
          let(:erlang_cookie)            { 'TESTCOOKIE' }
          let(:wipe_db_on_cookie_change) { true }
          it 'wipes the database' do
            should contain_exec('wipe_db')
            should contain_file('erlang_cookie')
          end
        end

        describe 'correctly when cookies match' do
          let(:config_cluster)           { true }
          let(:cluster_nodes)            { ['hare-1', 'hare-2'] }
          let(:cluster_node_type)        { 'ram' }
          let(:erlang_cookie)            { 'ORIGINAL' }
          let(:wipe_db_on_cookie_change) { true }
          it 'and doesnt wipe anything' do
            should contain_file('erlang_cookie')
          end
        end

        describe 'and sets appropriate configuration' do
          let(:config_cluster)           { true }
          let(:cluster_nodes)            { ['hare-1', 'hare-2'] }
          let(:cluster_node_type)        { 'ram' }
          let(:erlang_cookie)            { 'ORIGINAL' }
          let(:wipe_db_on_cookie_change) { true }
          it 'for cluster_nodes' do
            verify_contents(subject, 'rabbitmq.config',
            ['[',"{rabbit, [{cluster_nodes, {['rabbit@hare-1', 'rabbit@hare-2'], ram}}]}", '].'])
          end

          it 'for erlang_cookie' do
            verify_contents(subject, 'erlang_cookie',
            ['ORIGINAL'])
          end
        end
      end


      describe 'rabbitmq-env configuration' do
        it { should contain_file('rabbitmq-env.config') }
      end

      context 'configuration setting' do
        describe 'node_ip_address when set' do
          let(:node_ip_address) { '172.0.0.1' }
          it 'should set RABBITMQ_NODE_IP_ADDRESS to specified value' do
            verify_contents(subject, 'rabbitmq-env.config',
            ['RABBITMQ_NODE_IP_ADDRESS=172.0.0.1'])
          end
        end

        describe 'stomp by default' do
          it 'should not specify stomp parameters in rabbitmq.config' do
            verify_contents(subject, 'rabbitmq.config',
            ['[','].'])
          end
        end
        describe 'stomp when set' do
          let(:config_stomp) { true }
          let(:stomp_port) { '5679' }
          it 'should specify stomp port in rabbitmq.config' do
            verify_contents(subject, 'rabbitmq.config',
            ['[','{rabbitmq_stomp, [{tcp_listeners, [5679]} ]}','].'])
          end
        end
      end
    end
  end
end
