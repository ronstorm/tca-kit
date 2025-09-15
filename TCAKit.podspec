Pod::Spec.new do |s|
  s.name             = 'TCAKit'
  s.version          = '1.0.0'
  s.summary          = 'A lightweight, SwiftUI-first TCA-style state management library.'
  s.description      = <<-DESC
TCAKit is a small, production-friendly library inspired by The Composable Architecture.
It focuses on a tiny core: Store, Reducer, Effect, and Dependencies, with SwiftUI helpers
and test utilities. No heavy DI, zero external dependencies.
  DESC
  s.homepage         = 'https://github.com/ronstorm/tca-kit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Amit Sen' => 'opensource@ronstorm.dev' }
  s.source           = { :git => 'https://github.com/ronstorm/tca-kit.git', :tag => 'v' + s.version.to_s }

  s.swift_versions   = ['5.9', '6.0', '6.1']
  s.ios.deployment_target     = '15.0'
  s.osx.deployment_target     = '12.0'
  s.tvos.deployment_target    = '15.0'
  s.watchos.deployment_target = '8.0'

  # Default (core) subspec
  s.default_subspecs = 'Core'

  s.subspec 'Core' do |core|
    core.source_files = 'Sources/TCAKit/**/*.{swift}'
    core.exclude_files = [
      'Sources/TCAKit/Bridges/**/*',
      'Sources/TCAKit/Testing/**/*'
    ]
  end

  s.subspec 'CombineBridge' do |bridge|
    bridge.source_files = 'Sources/TCAKit/Bridges/**/*.{swift}'
    bridge.dependency 'TCAKit/Core'
  end

  s.subspec 'Testing' do |testing|
    testing.source_files = 'Sources/TCAKit/Testing/**/*.{swift}'
    testing.dependency 'TCAKit/Core'
  end
end


