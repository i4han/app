isVisible = (v) -> if 'function' == typeof v then v() else if false is v then false else true

module.exports.ui =
    html:
        HTML: '' 
        head: (C,_) -> _.slice "title #{C.title}|link(href='#{C._.font_style.pt_sans}' rel='stylesheet')"
        created: ->
            console.log Config.collections
            Config.collections.forEach (a) ->
                db[a] = new Meteor.Collection a if !db[a]?
                Meteor.subscribe [a]

    body: styl: (C,_) -> _.slice "body|>font-family #{C.$.font_family}|font-weight #{C.$.font_weight}"
    
    form:
        jade: """
            if visible
                .input-group.margin-bottom-sm
                   span.input-group-addon: i.fa.fa-fw(class="fa-{{icon}}")
                   input.form-control(id="{{id}}" type="{{type}}" placeholder="{{label}}" title="{{title}}" data-toggle="popover" data-trigger="hover" data-placement="right" data-html="true")
            """
        helpers:
            type: -> @type or "text"
            visible: -> isVisible(@visible)
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            title: -> @title
        styl$: """
            .popover
                font-family 'PT Sans', sans-serif
                width 200px
            .popover-title
                font-size 14px                
            .popover-content
                font-size 12px
                padding 5px 0px
            .popover-content > ul
                padding-left 32px
            .popover-inner
                width 100%
            """
    button:
        jade: """
            if visible
                button.btn(class="{{class}}" id="{{id}}" type="{{type}}") {{label}}
            """
        helpers:
            type: -> @type or "button"
            visible: -> isVisible(@visible)
            id: -> @id or __.dasherize @label.toLowerCase().trim()
            class: -> @class or 'btn-primary'
        styl$: """
            .btn
                font-family 'PT Sans'
                width 150px //166
                border 0
                margin-top 5px
            .btn-default
                background-color #f8f8f8  
            .btn-default 
            .btn-primary 
            .btn-success 
            .btn-info 
            .btn-warning 
            .btn-danger 
            .btn-default:hover
            .btn-primary:hover
            .btn-success:hover
            .btn-info:hover
            .btn-warning:hover
            .btn-danger:hover
                border 0
            """
    dialog:
        jade: """
            button.btn(href="#myModal" role="button" data-toggle="modal") Modal
            .modal.fade#myModal(tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true")
                .modal-dialog: .modal-content
                    .modal-header
                        button.close(type="button" data-dismiss="modal" aria-hidden="true") ×
                        h3#myModalLabel {{modalHeader}}
                    .modal-body
                        p {{modalBody}}
                    .modal-footer
                        button.btn(data-dismiss="modal" aria-hidden="true") {{modalCloseButton}}
                        button.btn.btn-primary {{modalActionButton}}
            """
        helpers:
            modalHeader: -> "Modal Header"
            modalBody: -> "One fine body!"
            modalCloseButton: -> "Close"
            modalActionButton: -> "Save Changes"
        styl$: """
            .modal-backdrop
                opacity: 0.50
            """
    a:
        jade: """
            if visible
                a(class="{{class}}" id="{{id}}") {{label}}
            """
        helpers:
            visible: -> isVisible(@visible)     # change password must put visible: true why?
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
            visible: -> isVisible(@visible)
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
            visible: -> isVisible(@visible) and @message
            class: -> @class or 'alert-success'
    br:
        jade$: "br(style='line-height:{{height}};')"

