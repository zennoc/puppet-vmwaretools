# == Class: vmwaretools::params
#
# This class handles parameters for the vmwaretools module, including the logic
# that decided if we should install a new version of VMware Tools.
#
# == Actions:
#
# None
#
# === Authors:
#
# Craig Watson <craig@cwatson.org>
#
# === Copyright:
#
# Copyright (C) 2013 Craig Watson
# Published under the GNU General Public License v3
#
class vmwaretools::params {

  if $::vmwaretools_version == 'not installed' {
    # If nothing is installed, deploy.
    $deploy_files = true
  } else {

    # If tools are installed, are we handling downgrades?
    if $vmwaretools::prevent_downgrade {

      if versioncmp($::vmwaretools_version,$vmwaretools::version) < 0 {
        # Only deploy if the installed version is **lower than** the Puppet version
        $deploy_files = true
      } else {
        $deploy_files = false
      }

    } else {

      # If we're not handling downgrades, deploy on version mismatch
      $deploy_files = $::vmwaretools_version ? {
        $vmwaretools::version => false,
        default               => true,
      }

    }
  }

  $awk_path = $::osfamily ? {
    'RedHat' => '/bin/awk',
    'Debian' => '/usr/bin/awk',
    default  => '/usr/bin/awk',
  }

  if $::osfamily == 'RedHat' and $::lsbmajdistrelease == '5' {
    if ('PAE' in $::kernelrelease) {
      $kernel_extension = regsubst($::kernelrelease, 'PAE$', '')
      $redhat_devel_package = "kernel-PAE-devel-${kernel_extension}"
    } elsif ('xen' in $::kernelrelease) {
      $kernel_extension = regsubst($::kernelrelease, 'xen$', '')
      $redhat_devel_package = "kernel-xen-devel-${kernel_extension}"
    } else {
      $redhat_devel_package = "kernel-devel-${::kernelrelease}"
    }
  } else {
    $redhat_devel_package = "kernel-devel-${::kernelrelease}"
  }

  $purge_package_list = ['open-vm-tools','open-vm-dkms', 'vmware-tools-services','open-vm-tools-desktop']
}
