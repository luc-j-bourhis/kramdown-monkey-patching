# Superscripts and subscripts
# ---------------------------
#
# The syntax is H~2~O and E=mc^2^
#
# The idea and the code are borrowed from this pull request
#
# https://github.com/gettalong/kramdown/pull/50/commits/c3bee051cc1bd394a204db5c5cdf4a5a3f8ff71a#diff-960bf3c029137a2a77da7d11dcd93b74R286
#
# which has never been accepted. Thus thanks to [Bran](https://github.com/unibr).
# Consequently, the license for this repository does not apply to this file,
# since this is not my work.

module Kramdown
    module Parser
        class Kramdown
            # Using "prepend" is the trick to make "super" works
            # in KramdownMonkeyPatching
            prepend KramdownMonkeyPatching

            # We may want to use ^ and ~ normally, so add them to
            # the list of characters which may be escaped
            ESCAPED_CHARS = Regexp.new(remove_const(:ESCAPED_CHARS)
                                       .to_s.sub(/\]/, "^~\\]"))

            # Regex used to detect ^ or ~
            SUPERSUB_START = /(\^|~)(?!\1)/

            # Parse ^bla bla^ and ~bla bla~
            # This results in elements of type :sup or :sub in the
            # parse tree
            def parse_supersub
                result = @src.scan(SUPERSUB_START)
                reset_pos = @src.pos
                char = @src[1]
                type = char == '^' ? :sup : :sub

                el = Element.new(type)
                stop_re = /#{Regexp.escape(char)}/
                found = parse_spans(el, stop_re)

                if found
                    @src.scan(stop_re)
                    @tree.children << el
                else
                    @src.pos = reset_pos
                    add_text(result)
                end
            end
            define_parser(:supersub, SUPERSUB_START, '\^|~')
        end
    end

    module Converter
        class Html < Base

            # Convert elements of type :sup to HTML
            def convert_sup(el, indent)
                format_as_span_html(el.type, el.attr, inner(el, indent))
            end

            # Convert elements of type :sub to HTML
            def convert_sub(el, indent)
                format_as_span_html(el.type, el.attr, inner(el, indent))
            end
        end
    end
end
