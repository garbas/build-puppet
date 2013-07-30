# === Class: concat::setup
#
# Sets up the concat system.
#
# [$concatdir]
#   is where the fragments live and is set on the fact concat_basedir.
#   Since puppet should always manage files in $concatdir and they should
#   not be deleted ever, /tmp is not an option.
#
# [$puppetversion]
#   should be either 24 or 25 to enable a 24 compatible
#   mode, in 24 mode you might see phantom notifies this is a side effect
#   of the method we use to clear the fragments directory.
#
# The regular expression below will try to figure out your puppet version
# but this code will only work in 0.24.8 and newer.
#
# It also copies out the concatfragments.sh file to ${concatdir}/bin
#
class concat::setup {
  include packages::diffutils # for cmp, used by concatfragments.sh
  $id = $::id
  $root_group = $id ? {
    root    => 0,
    default => $id
  }

  if $::concat_basedir {
    $concatdir = $::concat_basedir
  } else {
    fail ("\$concat_basedir not defined. Try running again with pluginsync=true on the [master] section of your node's '/etc/puppet/puppet.conf'.")
  }

  # OS-specific path chars, used to generate "safe" filenames
  $pathchars   = $::operatingsystem ? {
    Windows => '[/\\:\n]',
    default => '[/\n]',
  }

  $majorversion = regsubst($::puppetversion, '^[0-9]+[.]([0-9]+)[.][0-9]+$', '\1')
  $fragments_source = $majorversion ? {
    24      => 'puppet:///concat/concatfragments.rb',
    default => 'puppet:///modules/concat/concatfragments.rb'
  }

  file{"${concatdir}/bin/concatfragments.rb":
    owner  => $id,
    group  => $root_group,
    mode   => '0775',
    source => $fragments_source;

  [ $concatdir, "${concatdir}/bin" ]:
    ensure => directory,
    owner  => $id,
    group  => $root_group,
    mode   => '0770';

  # pre-windows-compatible versions used a shell script
  "${concatdir}/bin/concatfragments.sh":
    ensure => absent;
  }

  ## Old versions of this module used a different path.
  if $::operatingsystem != "Windows" {
    file{'/usr/local/bin/concatfragments.sh':
      ensure => absent;
    }
  }
}
