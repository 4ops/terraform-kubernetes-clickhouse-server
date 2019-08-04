data "template_file" "server_config" {
  template = <<-TEMPLATE
    <?xml version="1.0"?>
    <yandex>
      <listen_host>0.0.0.0</listen_host>
      <listen_try>1</listen_try>
      <http_port>8123</http_port>
      <tcp_port>9000</tcp_port>
      <keep_alive_timeout>${ var.keep_alive_timeout }</keep_alive_timeout>
      <max_concurrent_queries>${ var.max_concurrent_queries }</max_concurrent_queries>
      <max_connections>${ var.max_connections }</max_connections>
      <logger>
        <console>1</console>
        <level>warning</level>
        <log>/dev/null</log>
        <errorlog>/dev/null</errorlog>
      </logger>
      <!--
      <http_server_default_response>
        <![CDATA[<html ng-app="SMI2"><head><base href="http://ui.tabix.io/"></head><body><div ui-view="" class="content-ui"></div><script src="http://loader.tabix.io/master.js"></script></body></html>]]>
      </http_server_default_response>
      -->
      <path>/var/lib/clickhouse/</path>
      <tmp_path>/tmp/</tmp_path>
      <user_files_path>/var/lib/clickhouse/user_files/</user_files_path>
      <format_schema_path>format_schemas/</format_schema_path>
      <uncompressed_cache_size>${ var.uncompressed_cache_size }</uncompressed_cache_size>
      <mark_cache_size>${ var.mark_cache_size }</mark_cache_size>
      <users_config>users.xml</users_config>
      <default_profile>default</default_profile>
      <default_database>default</default_database>
      <builtin_dictionaries_reload_interval>3600</builtin_dictionaries_reload_interval>
      <max_session_timeout>3600</max_session_timeout>
      <default_session_timeout>60</default_session_timeout>
    </yandex>
  TEMPLATE
}

data "template_file" "users_config" {
  template = <<-TEMPLATE
    <?xml version="1.0"?>
    <yandex>
      <profiles>
        <default>
            <max_threads>8</max_threads>
        </default>
        <read_only>
          <readonly>1</readonly>
        </read_only>
      </profiles>
      <quotas>
        <default>
          <interval>
            <duration>3600</duration>
            <queries>0</queries>
            <errors>0</errors>
            <result_rows>0</result_rows>
            <read_rows>0</read_rows>
            <execution_time>0</execution_time>
          </interval>
        </default>
      </quotas>
      <users>
        <default>
            <password_sha256_hex>${ sha256(local.default_password) }</password_sha256_hex>
            <profile>default</profile>
            <quota>default</quota>
            <networks>
              <ip>10.0.0.0/8</ip>
              <ip>172.16.0.0/12</ip>
              <ip>192.168.0.0/16</ip>
            </networks>
        </default>
        <${ var.exporter_username }>
            <password_sha256_hex>${ sha256(random_string.exporter_password.result) }</password_sha256_hex>
            <profile>read_only</profile>
            <quota>default</quota>
            <networks>
              <ip>127.0.0.0/8</ip>
            </networks>
        </${ var.exporter_username }>
        %{ for user in var.clickhouse_users }
        <${ user.name }>
            <password_sha256_hex>${ sha256(user.password) }</password_sha256_hex>
            <profile>${ user.read_only ? "read_only" : "default" }</profile>
            <quota>default</quota>
            <networks>
              <ip>10.0.0.0/8</ip>
              <ip>172.16.0.0/12</ip>
              <ip>192.168.0.0/16</ip>
              %{ if user.remote }
              <ip>0.0.0.0/0</ip>
              %{ endif }
            </networks>
            <allow_databases>
              <database>${ user.database }</database>
            </allow_databases>
        </${ user.name }>
        %{ endfor }
      </users>
    </yandex>
  TEMPLATE
}
