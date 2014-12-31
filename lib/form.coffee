is_visible = -> if @visible == undefined then true else if typeof @visible == 'function' then @visible() else @visible

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
        styl_compile: """
            .btn
                margin-top 5px
            """
        jade: """
            if visible
                button.btn(class="{{class}}" id="{{id}}" type="{{type}}") {{label}}
            """
        helpers:
            type: -> this.type or "button"
            visible: -> if @visible == undefined then true else if typeof @visible == 'function' then @visible() else @visible
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            title: -> @title
            class: -> @class or 'btn-primary'
    link:
        jade: """
            if visible
                a(class="{{class}}" id="{{id}}") {{label}}
            """
        helpers:
            visible: -> if @visible == undefined then true else if typeof @visible == 'function' then @visible() else @visible
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            class: -> @class
    menu:
        jade: """
            if visible
                if divider
                    li.divider
                else
                    li: a(id="{{id}}" class="{{class}}" style="{{style}}")
                        i.fa(class="fa-{{icon}}" class="{{icon_class}}")
                        | {{label}}
            """
        helpers:
            visible: -> is_visible() 
            id: -> @id
            icon: -> @icon
            class: -> @class or 'menu-list'
            style: -> @style
            icon_class: -> @icon_class or 'dropdown-menu-icon'
            label: -> @label
            divider: -> true if @label is '-'
    alert:
        jade: """
            if visible
                .alert(class="{{class}}") {{message}}
            """
        helpers:
            visible: -> is_visible() and @message
            class: -> @class or 'alert-success'