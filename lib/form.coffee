module.exports.form =

    formField:
        jade: """
            if visible
                .input-group.margin-bottom-sm
                    span.input-group-addon: i.fa.fa-fw(class="fa-{{icon}}")
                    input.form-control(id="{{name}}" type="{{type}}" placeholder="{{label}}" title="{{title}}" data-toggle="popover" data-trigger="hover" data-placement="right" data-html="true")
            """
        helpers:
            type: -> this.type or "text"
            visible: -> if this.visible == undefined then true else if typeof this.visible == 'function' then this.visible() else this.visible
            name: -> this.name or __.dasherize this.label.toLowerCase().trim()
            title: -> this.title
        stylus: """
            .popover
                width 240px
            .popover-inner
                width 100%
            """

