
isVisible = (v) -> if 'function' == typeof v then v() else if false is v then false else true

module.exports.ui =
    html:
        jade: ' '
        head: ->
            title: @Settings.title
            1: "link(rel='stylesheet' href='#{@Theme.font_stylesheet}')"
            #2: "script(type='text/javascript' src='https://maps.googleapis.com/maps/api/js?key=AIzaSyB2RuPxiq1JbG18Lq793FdEzWM-7-MYX8Q')"
            #3: "script(type='text/javascript' src='<%= @googlemap %>')"
            #4: "script(type='text/javascript' src='https://maps.googleapis.com/maps/api/js?v=3.exp&signed_in=true&libraries=places')"
            4: "script(type='text/javascript' src='<%= @googlemap_input %>')"
            5: "meta(name='viewport', content='initial-scale=1.0, user-scalable=no')"
            6: "meta(charset='utf-8')"
        eco: -> googlemap_input: -> x.urlWithQuery Settings.private.google.map_input
        startup: ->
            ''
        styl: -> 
            html: height: '100%'
            body: 
                height: '100%'
                fontFamily: @Theme.font_family
                fontWeight: @Theme.font_weight   
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
            id: -> @id or x.dasherize @label.toLowerCase().trim()
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
    address:
        css: """
          html, body, #map-canvas {
            height: 100%;
            margin: 0px;
            padding: 0px
          }
          .controls {
            margin-top: 16px;
            border: 1px solid transparent;
            border-radius: 2px 0 0 2px;
            box-sizing: border-box;
            -moz-box-sizing: border-box;
            height: 32px;
            outline: none;
            box-shadow: 0 2px 6px rgba(0, 0, 0, 0.3);
          }

          #pac-input {
            background-color: #fff;
            font-family: Roboto;
            font-size: 15px;
            font-weight: 300;
            margin-left: 12px;
            padding: 0 11px 0 13px;
            text-overflow: ellipsis;
            width: 400px;
          }

          #pac-input:focus {
            border-color: #4d90fe;
          }

          .pac-container {
            font-family: Roboto;
          }

          #type-selector {
            color: #fff;
            background-color: #4d90fe;
            padding: 5px 11px 0px 11px;
          }

          #type-selector label {
            font-family: Roboto;
            font-size: 13px;
            font-weight: 300;
          }"""

    button:
        jade: """
            if visible
                button.btn(class="{{class}}" id="{{id}}" type="{{type}}") {{label}}
            """
        helpers:
            type: -> @type or "button"
            visible: -> isVisible(@visible)
            id: -> @id or x.dasherize @label.toLowerCase().trim()
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
            id: -> @id or x.dasherize @label.toLowerCase().trim()
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

