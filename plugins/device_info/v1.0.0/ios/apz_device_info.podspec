Pod::Spec.new do |s|
  s.name             = 'apz_device_info'
  s.version          = '1.0.0'
  s.summary          = 'A new Flutter plugin for device info.'
  s.description      = <<-DESC
                       A new Flutter plugin for device info.
                       DESC
  s.homepage         = 'https://your.plugin.homepage/'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'you@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.swift_versions = ['5.0', '5.1', '5.2', '5.3', '5.4', '5.5', '5.6', '5.7', '5.8', '5.9', '5.10']
  s.platform     = :ios, '14.0'
end