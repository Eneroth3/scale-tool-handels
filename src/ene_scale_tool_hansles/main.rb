# Eneroth Scale Tool Handles

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

module EneScaleToolHandles

  # Wrapper class to handle scale handle masks.
  # Instead of setting each type of handle separately this wrapper
  # handles each axes, 2D diagonals and 3D diagonals.
  class ScaleMask

    NO_X_SCALE_MASK   = 0b00000001
    NO_Y_SCALE_MASK   = 0b00000010
    NO_Z_SCALE_MASK   = 0b00000100
    NO_XZ_SCALE_MASK  = 0b00001000
    NO_YZ_SCALE_MASK  = 0b00010000
    NO_XY_SCALE_MASK  = 0000100000
    NO_XYZ_SCALE_MASK = 0b00100000

    def initialize(definition)
      @definition = definition
      @no_scale_mask = definition.behavior.no_scale_mask?
    end

    def allow_x=(v)
      v ? @no_scale_mask &= ~NO_X_SCALE_MASK : @no_scale_mask |= NO_X_SCALE_MASK
      apply
    end

    def allow_x?
      (@no_scale_mask & NO_X_SCALE_MASK) == 0
    end

    def allow_y=(v)
      v ? @no_scale_mask &= ~NO_Y_SCALE_MASK : @no_scale_mask |= NO_Y_SCALE_MASK
      apply
    end

    def allow_y?
      (@no_scale_mask & NO_Y_SCALE_MASK) == 0
    end

    def allow_z=(v)
      v ? @no_scale_mask &= ~NO_Z_SCALE_MASK : @no_scale_mask |= NO_Z_SCALE_MASK
      apply
    end

    def allow_z?
      (@no_scale_mask & NO_Z_SCALE_MASK) == 0
    end

    # TODO: How should this value be acquired?
    def allow_2d?
    end

    def inspect
      @no_scale_mask.to_s(2)
    end

    private

    def apply
      @definition.behavior.no_scale_mask = @no_scale_mask
      p @definition.behavior.no_scale_mask?
    end

  end

  UI.add_context_menu_handler do |menu|
    model = Sketchup.active_model
    entity = model.selection.first
    next unless entity.is_a?(Sketchup::ComponentInstance)
    ms = ScaleMask.new(entity.definition)

    item = menu.add_item("Scale X") { ms.allow_x = !ms.allow_x? }
    menu.set_validation_proc(item) { ms.allow_x? ? MF_CHECKED : MF_UNCHECKED }

    item = menu.add_item("Scale Y") { ms.allow_y = !ms.allow_y? }
    menu.set_validation_proc(item) { ms.allow_y? ? MF_CHECKED : MF_UNCHECKED }

    item = menu.add_item("Scale Z") { ms.allow_z = !ms.allow_z? }
    menu.set_validation_proc(item) { ms.allow_z? ? MF_CHECKED : MF_UNCHECKED }

    menu.add_separator
  end

end
