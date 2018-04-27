require 'spec_helper'

describe 'package_alternatives' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      context 'no alternatives' do
        let(:title) { 'foo' }

        let(:params) do
          {
            'ensure'    => 'present',
            'pkg_alias' => 'myfoo',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('foo').with(
            'ensure' => 'present',
            'alias'  => 'myfoo',
          )
        }
      end

      context 'with string alternative' do
        let(:title) { 'foo' }

        let(:params) do
          {
            'ensure'       => 'present',
            'alternatives' => 'nofoo',
            'pkg_alias'    => 'myfoo',
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('nofoo').with(
            'ensure' => 'present',
            'alias'  => 'myfoo',
          )
        }
      end

      context 'with hash alternatives' do
        let(:title) { 'man-db' }

        let(:params) do
          {
            'ensure'       => 'latest',
            'fail_missing' => true,
            'alternatives' => {
              'debian'   => 'man-db',
              'redhat-5' => 'man',
              'redhat-6' => 'man',
              'redhat'   => 'man-db',
              'sles'     => 'man',
              'sled'     => 'man',
            },
          }
        end

        it { is_expected.to compile }

        it {
          package = case os_facts[:os]['name']
                    when 'Debian', 'Ubuntu'
                      'man-db'
                    when 'RedHat', 'CentOS', 'Scientific', 'OracleLinux', 'Fedora'
                      if os_facts[:os]['release']['major'] =~ %r{^[56]$}
                        'man'
                      else
                        'man-db'
                      end
                    when 'SLES', 'SLED'
                      'man'
                    end

          is_expected.to contain_package(package).with(
            'ensure' => 'latest',
            'alias'  => 'man-db',
          )
        }
      end

      context 'with platform override' do
        let(:title) { 'foo' }

        let(:params) do
          {
            'ensure'       => 'present',
            'platform'     => 'myplatform',
            'alternatives' => {
              'debian'     => 'man-db',
              'redhat-5'   => 'man',
              'redhat-6'   => 'man',
              'redhat'     => 'man-db',
              'sles'       => 'man',
              'sled'       => 'man',
              'myplatform' => 'myfoo',
            },
          }
        end

        it { is_expected.to compile }

        it {
          is_expected.to contain_package('myfoo').with(
            'ensure' => 'present',
            'alias'  => 'foo',
          )
        }
      end

      context 'fail with missing alternatives' do
        let(:title) { 'man-db' }

        let(:params) do
          {
            'ensure'       => 'absent',
            'fail_missing' => true,
            'alternatives' => {
              'invalid' => 'man-db',
            },
          }
        end

        it { is_expected.not_to compile }
      end

      context 'pass with missing alternatives' do
        let(:title) { 'man-db' }

        let(:params) do
          {
            'ensure'       => 'absent',
            'fail_missing' => false,
            'alternatives' => {
              'invalid' => 'man-db',
            },
          }
        end

        it { is_expected.to compile }
        it { is_expected.not_to contain_package('man-db') }
      end
    end
  end
end
