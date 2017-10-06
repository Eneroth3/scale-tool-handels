# Eneroth Scale Tool Handles

# Copyright Julia Christina Eneroth, eneroth3@gmail.com

module EneScaleToolHandles

  class BitMask

    def initialize(mask_integer)
      @mask = mask_integer
    end

    def []=(index, value)
      value_mask = 1 << index
      value ? @mask |= value_mask : @mask &= ~value_mask
    end

    def [](index)
      (@mask & (1 << index)) != 0
    end

    def inspect
      @mask.to_s(2)
    end

    def to_i
      @mask
    end

  end

end
