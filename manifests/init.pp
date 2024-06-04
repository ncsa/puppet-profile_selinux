# @summary profile to manage SELinux
#
# @param enable
#   Boolean of state of SELinux
#
# @example
#   include profile_selinux
class profile_selinux (
  Boolean $enable,
) {
  case $facts['os']['family'] {
    'RedHat': {
      if $enable {
        exec { 'enable selinux':
          command => '/usr/sbin/setenforce 1',
          unless  => "/usr/sbin/sestatus | /bin/grep -i 'status' | /bin/egrep -i 'enabled'",
        }
        file_line { 'set selinux to enforcing':
          ensure => 'present',
          path   => '/etc/selinux/config',
          line   => 'SELINUX=enforcing',
          match  => '^SELINUX=.*$',
        }
      }
      else {
        exec { 'disable selinux':
          command => '/usr/sbin/setenforce 0',
          unless  => "/usr/sbin/sestatus | /bin/grep -i 'status' | /bin/egrep -i 'disabled|permissive'",
        }
        file_line { 'set selinux to disabled':
          ensure => 'present',
          path   => '/etc/selinux/config',
          line   => 'SELINUX=disabled',
          match  => '^SELINUX=.*$',
        }
      }
    }
    'Suse': {
      if $enable {
        exec { 'enable selinux':
          command => '/usr/sbin/setenforce 1',
          unless  => "/usr/sbin/getenforce | /bin/egrep -i 'enabled'",
        }
        # SELinux boot option set via GRUB_CMDLINE_LINUX_DEFAULT parameter in /etc/default/grub
      }
      else {
        exec { 'disable selinux':
          command => '/usr/sbin/setenforce 0',
          unless  => "/usr/sbin/getenforce | /bin/egrep -i 'disabled|permissive'",
        }
        # SELinux boot option set via GRUB_CMDLINE_LINUX_DEFAULT parameter in /etc/default/grub
      }
    }
    default: {
      fail('Only RedHat and Suse are supported at this time')
    }
  }
}
