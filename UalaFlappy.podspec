Pod::Spec.new do |s|
  s.name             = 'UalaFlappy'
  s.version          = '0.0.3'
  s.summary          = 'Flappy Uala module.'
  s.swift_version    = '5.4'
  s.description      = 'Flappy bird style game for iOS.'

  s.homepage         = 'git@github.com:ladelfamooveit/flappy-game.git'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Matias' => 'matias.ladelfa@qubika.com' }
  s.source           = { :git => 'git@github.com:ladelfamooveit/flappy-game.git', :tag => s.version.to_s }

  s.source_files = 'UalaFlappy/Classes/**/*'
  
  s.resource_bundles = {
    'Flappy' => [
    'UalaFlappy/Classes/**/*.xib',
    'UalaFlappy/Assets/*.strings',
    'UalaFlappy/Assets/**/*.sks',
    'UalaFlappy/Assets/**/*.fsh',
    'UalaFlappy/Assets/**/*.gif',
    'UalaFlappy/Assets/**/*.json',
    'UalaFlappy/Assets/**/*.wav',
    'UalaFlappy/Assets/**/*.mp3',
    'UalaFlappy/Assets/**/*.otf',
    'UalaFlappy/Assets/**/*.xcassets',
    'UalaFlappy/Assets/*.xcassets',
    'UalaFlappy/Assets/**/*.png'
    ]
  }
  
  s.ios.deployment_target = '13.0'

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  #s.dependency 'UalaUI'
  #s.dependency 'UalaCore'
  #s.dependency 'UalaUtils'
end
