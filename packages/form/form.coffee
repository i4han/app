module.exports.form =

    form:
        jade: """
            if visible
                .input-group.margin-bottom-sm
                    span.input-group-addon: i.fa.fa-fw(class="fa-{{icon}}")
                    input.form-control(id="{{id}}" type="{{type}}" placeholder="{{label}}" title="{{title}}" data-toggle="popover" data-trigger="hover" data-placement="right" data-html="true")
            """
        helpers:
            type: -> @type or "text"
            visible: -> if @visible == undefined then true else if typeof @visible == 'function' then @visible() else @visible
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            title: -> @title
        styl_compile: """
            .popover
                width 240px
            .popover-inner
                width 100%
            """
    button:
        jade: """
            if visible
                button.btn.btn-primary(id="{{id}}" type="{{type}}") {{label}}

            """
        helpers:
            type: -> this.type or "button"
            visible: -> if @visible == undefined then true else if typeof @visible == 'function' then @visible() else @visible
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            title: -> @title
    link:
        jade: """
            if visible
                a(class="{{class}}" id="{{id}}") {{label}}

            """
        helpers:
            visible: -> if @visible == undefined then true else if typeof @visible == 'function' then @visible() else @visible
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            class: -> @class
