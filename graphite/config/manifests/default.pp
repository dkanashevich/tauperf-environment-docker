Exec {
    path => ["/usr/bin", "/usr/sbin", '/bin']
}

file { '/etc/issue':
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',		
	source => "/config/files/issue"
}

$packages = ["graphite-web", "graphite-carbon", "apache2", "libapache2-mod-wsgi", "npm", "nodejs-legacy"]

package { $packages: ensure => installed }

package { "statsd":
	ensure => installed,
	provider => dpkg,
	source => "/config/statsd_0.7.2_all.deb",
	require => Package["npm", "nodejs-legacy"]
}

file { "/etc/apache2/sites-available/apache2-graphite.conf": 
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',		
	source => "/usr/share/graphite-web/apache2-graphite.conf",
	require => Package["graphite-carbon", "apache2", "libapache2-mod-wsgi"]
} ->
exec { 'enable graphite site in apache':
	command => 'a2dissite 000-default && a2ensite apache2-graphite && service apache2 restart',
}

file_line { "add secret_key": 
	path => "/etc/graphite/local_settings.py",
	line => "SECRET_KEY = 'f9tGJSEGaBEPQZcK2CU5'",
	require => Package["graphite-carbon"]
} ->
exec { 'syncdb':
	command => "graphite-manage syncdb --noinput"
} ->
exec { 'add permissions for db':
	command => 'chmod a+rw /var/lib/graphite/graphite.db'
} 

file { "/etc/carbon/carbon.conf": 
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',
	source => "/config/files/carbon.conf",
	require => Package["graphite-carbon"]
}

file { "/etc/default/graphite-carbon": 
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',
	source => "/config/files/graphite-carbon"
}

file { "/etc/carbon/storage-schemas.conf":
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',		
	source => "/config/files/storage-schemas.conf",
	require => Package["graphite-carbon"]
}

file { "/etc/carbon/storage-aggregation.conf":
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',
	source => "/config/files/storage-aggregation.conf",
	require => Package["graphite-carbon"]
}

file { "/etc/statsd/localConfig.js":
	ensure => file,
	owner  => 'root',
	group  => 'root',
	mode   => '0644',		
	source => "/config/files/statsd.localConfig.js",
	require => Package["statsd"]
}

service { 'carbon-cache':
	ensure => running,
	enable => true,
	subscribe => [
		File["/etc/default/graphite-carbon"],
		File["/etc/carbon/storage-schemas.conf"],
		File["/etc/carbon/storage-aggregation.conf"]
	],
	require => Package["graphite-carbon"]
}

service { 'statsd':
	ensure => running,
	subscribe => File["/etc/statsd/localConfig.js"],
	require => Package['statsd']
}
