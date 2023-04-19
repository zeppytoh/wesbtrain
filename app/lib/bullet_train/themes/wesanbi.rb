module BulletTrain
  module Themes
    module Wesanbi
      class Theme < BulletTrain::Themes::Light::Theme
        def directory_order
          ["wesanbi"] + super
        end
      end
    end
  end
end
