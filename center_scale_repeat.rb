require 'sketchup.rb'

module CenterScaleRepeat
  @current_scale = 1.03

  def self.scale_from_center
    model = Sketchup.active_model
    selection = model.selection
    
    if selection.empty?
      UI.beep
      return
    end

    prompts = ["倍率 (例: 1.03 = 拡大, 0.97 = 縮小): "]
    defaults = [@current_scale]
    input = UI.inputbox(prompts, defaults, "中央基準スケール設定")
    
    return unless input
    @current_scale = input[0].to_f

    model.start_operation("Center Scale Repeat", true)

    begin
      combined_bounds = Geom::BoundingBox.new
      selection.each { |ent| combined_bounds.add(ent.bounds) }
      center_point = combined_bounds.center

      transform = Geom::Transformation.scaling(center_point, @current_scale, @current_scale, @current_scale)
      model.active_entities.transform_entities(transform, selection.to_a)

    rescue => e
      UI.messagebox("Error: #{e.message}")
    ensure
      model.commit_operation
    end
  end

  unless file_loaded?(__FILE__)
    menu = UI.menu("Plugins")
    # メニューに表示される名前も分かりやすく変更
    menu.add_item("Center Scale Repeat") {
      self.scale_from_center
    }
    file_loaded(__FILE__)
  end
end