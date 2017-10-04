# Eneroth Scale Tool Handles

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

module EneScaleToolHandles

  # Wrapper class to handle scale handle masks.
  # Instead of setting each type of handle separately this wrapper
  # handles each axes, 2D diagonals and 3D diagonals.
  class ScaleMask

    NO_X_SCALE   = 0
    NO_Y_SCALE   = 1
    NO_Z_SCALE   = 2
    NO_XZ_SCALE  = 3
    NO_YZ_SCALE  = 4
    NO_XY_SCALE  = 5
    NO_XYZ_SCALE = 6

    def initialize(definition)
      @definition = definition
      @no_scale_mask = definition.behavior.no_scale_mask?
    end

    def allow_x=(v)
      @no_scale_mask = self.class.set_bit(@no_scale_mask, NO_X_SCALE, !v)
      apply
    end

    def allow_x?
      !self.class.bit?(@no_scale_mask, NO_X_SCALE)
    end

    def allow_y=(v)
      @no_scale_mask = self.class.set_bit(@no_scale_mask, NO_Y_SCALE, !v)
      apply
    end

    def allow_y?
      !self.class.bit?(@no_scale_mask, NO_Y_SCALE)
    end

    def allow_z=(v)
      @no_scale_mask = self.class.set_bit(@no_scale_mask, NO_Z_SCALE, !v)
      apply
    end

    def allow_z?
      !self.class.bit?(@no_scale_mask, NO_Z_SCALE)
    end

    # TODO: How should this value be acquired?
    def allow_2d?
    end

    def inspect
      @no_scale_mask.to_s(2)
    end

    private

    # REVIEW: Create separate bitmask class with these on?

    def self.set_bit(bitmask, index, value)
      value_mask = 1 << index
      value ? bitmask |= value_mask : bitmask &= ~value_mask
    end

    def self.bit?(bitmask, index)
      (bitmask & (1 << index)) != 0
    end

    def apply
      @definition.behavior.no_scale_mask = @no_scale_mask
    end

  end

  UI.add_context_menu_handler do |menu|
    model = Sketchup.active_model
    entity = model.selection.first
    next unless entity.is_a?(Sketchup::ComponentInstance)# TODO: Make work on groups too!
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
