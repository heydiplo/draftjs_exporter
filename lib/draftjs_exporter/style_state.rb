# frozen_string_literal: true
module DraftjsExporter
  class StyleState
    attr_reader :styles, :style_map

    def initialize(style_map)
      @styles = []
      @style_map = style_map
    end

    def apply(command)
      case command.name
      when :start_inline_style
        styles.push(command.data)
      when :stop_inline_style
        styles.delete(command.data)
      end
    end

    def text?
      styles.empty?
    end

    def element_attributes
      return {} unless styles.any?

      current_styles = styles.map { |style| style_map.fetch(style) }

      class_name = class_name_from_styles(current_styles)
      css = styles_css_from_styles(current_styles)

      { style: css, class: class_name }
    end

    def styles_css_from_styles(current_styles)
      current_styles.inject({}, :merge).map { |key, value|
        next if key == :className

        "#{hyphenize(key)}: #{value};"
      }.join
    end

    def class_name_from_styles(current_styles)
      current_styles.map { |style| style[:className] }.compact.join(' ')
    end

    def hyphenize(string)
      string.to_s.gsub(/[A-Z]/) { |match| "-#{match.downcase}" }
    end
  end
end
