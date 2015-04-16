
module.exports.ui =
    html:
        jade: ' '
        head: ->
            title: @Settings.title
            1: "link(rel='stylesheet' href='#{@Theme.fontStylesheet}')"
            #2: "script(type='text/javascript' src='<%= @googlemap %>')"
            3: "script(type='text/javascript' src='<%= @googlemap_input %>')"
            4: "meta(name='viewport', content='initial-scale=1.0, user-scalable=no')"
            5: "meta(charset='utf-8')"
        eco: -> googlemap_input: -> x.urlWithQuery Settings.google.map_input
        styl: -> 
            html: height: '100%'
            body: 
                height: '100%'
                fontFamily: @Theme.fontFamily
                fontWeight: @Theme.fontWeight   
    form:
        jade: """
            if visible
                .input-group.margin-bottom-sm
                   span.input-group-addon: i.fa.fa-fw(class="fa-{{icon}}")
                   input.form-control(id="{{id}}" type="{{type}}" placeholder="{{label}}" title="{{title}}" data-toggle="popover" data-trigger="hover" data-placement="right" data-html="true")
            """
        helpers:
            type: -> @type or "text"
            visible: -> x.isVisible(@visible)
            id: -> @id or x.dasherize @label.toLowerCase().trim()
            title: -> @title
        styl$: 
            '.popover': fontFamily: "'PT Sans', sans-serif", width: 200
            '.popover-title': fontSize: 14
            '.popover-content': fontSize: 12, padding: '5px 0px'
            '.popover-content > ul': paddingLeft: 32
            '.popover-inner': width: '100%'
            
    address:
        styl:
            'html, body, #map-canvas': height: '100%', margin: 0, padding: 0
            '.controls': 
                marginTop: 16, border: '1px solid transparent', borderRadius: '2px 0 0 2px',
                boxSizing: 'border-box', MozBoxSizing: 'border-box', height: 32, outline: 'none', 
                boxShadow: '0 2px 6px rgba(0, 0, 0, 0.3)'
            '#pac-input':
                backgroundColor: '#fff', fontSize: 15, fontWeight: '300' #,fontFamily: 'Roboto'
                marginLeft: 12, padding: '0 11px 0 13px', textOverflow: 'ellipsis', width: 400
            '#pac-input:focus': borderColor: '#4d90fe'
            #'.pac-container': fontFamily: 'Roboto'
            '#type-selector': color: '#fff', backgroundColor: '#4d90fe', padding: '5px 11px 0px 11px'
            '#type-selector label': fontSize: 13, fontWeight: '300' # fontFamily: 'Roboto', 

    button:
        jade: """
            if visible
                button.btn(class="{{class}}" id="{{id}}" type="{{type}}") {{label}}
            """
        helpers:
            type: -> @type or "button"
            visible: -> x.isVisible(@visible)
            id: -> @id or x.dasherize @label.toLowerCase().trim()
            class: -> @class or 'btn-primary'
        styl$: 
            '.btn': fontFamily: 'PT Sans', width: 150, border: 0, marginTop: 5
            '.btn-default': backgroundColor: '#f8f8f8'
            '.btn-primary': border: 0
            '.btn-success': border: 0
            '.btn-info': border: 0
            '.btn-warning': border: 0 
            '.btn-danger': border: 0
            '.btn-default:hover': border: 0
            '.btn-primary:hover': border: 0
            '.btn-success:hover': border: 0
            '.btn-info:hover': border: 0
            '.btn-warning:hover': border: 0
            '.btn-danger:hover': border: 0
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
        styl$: '.modal-backdrop': opacity: '0.50'
    a:
        jade: """
            if visible
                a(class="{{class}}" id="{{id}}") {{label}}
            """
        helpers:
            visible: -> x.isVisible(@visible)     # change password must put visible: true why?
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
            visible: -> x.isVisible(@visible)
            id: -> @id
            icon: -> @icon
            class: -> @class or 'menu-list'
            style: -> @style
            icon_class: -> @icon_class or 'dropdown-menu-icon'
            label: -> @label
            divider: -> true if @label is '-'
    alert:
        jade: 
            'if visible': '.alert(class="{{class}}") {{message}}': ''
        helpers:
            visible: -> x.isVisible(@visible) and @message
            class: -> @class or 'alert-success'

    br: jade$: "br(style='line-height:{{height}};')"

