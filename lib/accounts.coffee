
resetMessages = ->
    Session.set 'login.errorMessage', null
    Session.set 'login.infoMessage' , null
    
closeDropdown = ->
    ('inSignupFlow inForgotPasswordFlow inChangePasswordFlow inMessageOnlyFlow dropdownVisible'.split ' ').forEach (key) ->
        Session.set 'login.' + key , false
    resetMessages()
    
orTest = -> (array) ->
    array.forEach (key) -> return true if Session.get key 
    false

ensureMessageVisible = ->
    if ! orTest 'resetPasswordToken enrollAccountToken justVerifiedEmail'.split ' '
        Session.set 'dropdownVisible', true

errorMessage = (message) ->
    message = if message then message else "Unknown error"
    Session.set "login.errorMessage", message
    Session.set "login.infoMessage", null
    ensureMessageVisible()
    
infoMessage = (message) ->
    Session.set "login.errorMessage", null
    Session.set "login.infoMessage", message
    ensureMessageVisible()
 
login = ->
    resetMessages();
    username = x.getValue('username');
    email = x.getValue('email');
    usernameOrEmail = x.trim(x.getValue('username-or-email'));
    password = x.getValue('password');
    loginSelector = null
    loginSelector = username: username if username?
    loginSelector = email: email if email?
    loginSelector = usernameOrEmail;
    Meteor.loginWithPassword loginSelector, password, (err, result) -> 
        if err then errorMessage err.reason else closeDropdown()

signup = ->
    resetMessages()
    options =
        username: x.trimmedValue 'username'
        email: x.trimmedValue 'email'
        password: x.getValue 'password'
        profile: {}
    Accounts.createUser options, (err) ->
        if err then errorMessage err.reason else closeDropdown()

changePassword = ->
    resetMessages()
    oldPassword = x.getValue 'old-password'
    password = x.getValue 'password'
    Accounts.changePassword oldPassword, password, (err) ->
       if err
           errorMessage err.reason
       else 
           infoMessage "Password changed"
           x.timeout 2400, ->
               resetMessages()
               closeDropdown()
               $('#login-dropdown').removeClass 'open'
forgotPassword = ->
    resetMessages();
    email = x.trimmedValue "forgot-password-email"
    infoMessage "Email sent"


get_username = ->
    user = Meteor.user()  
    return 'no name' if !user?    
    (user.profile and user.profile.name) or user.username or (user.emails and user.emails[0] and user.emails[0].address)

loginFlow = -> ! Session.get('login.inSignupFlow') and ! Session.get('login.inForgotPasswordFlow')    

#        styl$: (C,_) -> _.slice """#login-buttons|>float right|border 0 ~
#            |<#login-buttons + li .dropdown-menu |>float right|right 0|left auto"""
#        jade:  (C,_) -> _.slice "ul.nav.navbar-nav#login-buttons|>+Template.dynamic(template=template)"
###
        jade: (C,_) -> 
            _.slice """li.dropdown#login-dropdown ~
                |>a.dropdown-toggle#login-id(data-toggle='dropdown') {{username}}|>i.fa(class='fa-chevron-down') ~
                |<.dropdown-menu(id='{{id}}')|>+Template.dynamic(template=template)"""
        styl$: (C,_) -> _.slice """#logged-in-dropdown-menu|>right 0|left auto
                width #{C.$.navbar.login.dropdown.width}
                padding 5px 0px
            #login-dropdown input
                margin-bottom 0px
                border-radius 0px 5px 5px 0px
            .dropdown-menu
                width   #{C.$.navbar.dropdown.width}
                padding #{C.$.navbar.dropdown.padding}
            """
###

module.exports.accounts =

    login: 
        styl$: 
            '#login-buttons':float:'right',border:0
            '#login-buttons + li .dropdown-menu':float:'right',right:0,left:'auto'
        jade: 'ul.nav.navbar-nav#login-buttons':'+Template.dynamic(template=template)':''
        events:
            'click input, click label, click button, click .dropdown-menu, click .alert': (event) -> event.stopPropagation()
            'click .login-close': -> closeDropdown() ; $('#login-dropdown').removeClass 'open' ; console.log "login-close"
            'click #login-name-link, click #login-sign-in-link': (event) -> 
                event.stopPropagation()
                Session.set 'login.dropdownVisible', true
                Meteor.flush()
        helpers: template: ->
            'dropdown_' + if !Meteor.user() then 'logged_out' 
            else if Meteor.loggingIn() then 'logging_in' else 'logged_in'

    dropdown_logged_in:
        jade:  
            'li.dropdown#login-dropdown':
                'a.dropdown-toggle#login-id(data-toggle="dropdown")':
                    '{{username}}':''
                    'i.fa(class="fa-chevron-down")':''
                '.dropdown-menu(id="{{id}}")':
                    '+Template.dynamic(template=template)':''
        styl$: ->
            '#logged-in-dropdown-menu':
                right:0, left:'auto'
                width: @C.$.navbar.login.dropdown.width
                padding: '5px 0px'
            '#login-dropdown input':
                marginBottom: 0
                borderRadius: '0px 5px 5px 0px'
            '.dropdown-menu':
                width:   @C.$.navbar.dropdown.width
                padding: @C.$.navbar.dropdown.padding
        helpers:
            template: -> 
                if      Session.get 'login.inMessageOnlyFlow'    then 'login_messages' 
                else if Session.get 'login.inChangePasswordFlow' then 'change_password' 
                else    'dropdown_menu_logged_in'
            id: -> 
                if   Session.get('login.inMessageOnlyFlow') or Session.get('login.inChangePasswordFlow') 
                then 'logged-in-dropdown' else 'logged-in-dropdown-menu'
            username: -> get_username()

    dropdown_menu_logged_in:
        styl$: (C,_) -> """
            .dropdown-menu a
                display block
                padding 0px 8px
                height #{C.$.navbar.dropdown.a.height}
            .dropdown-menu a:hover
                cursor pointer
                background-color: #{C.$.navbar.dropdown.a.hover.background_color}
            #logged-in-dropdown-menu > li > a
                height 30px
                padding 7px 20px
            """
        jade: 'each items': '+menu': ''
        helpers: items: -> [
            { label: 'Profile',         id: 'menu-profile',         icon: 'list-alt' },
            { label: 'Settings',        id: 'menu-settings',        icon: 'cog'      },
            { label: 'Change Password', id: 'menu-change-password', icon: 'key'      },
            { label: '-' },
            { label: 'Sign Out',        id: 'menu-logout',          icon: 'sign-out' }]
        events:
            'click #menu-logout':   -> Meteor.logout -> closeDropdown()        ; Router.go 'home'
            'click #menu-profile':  -> $('#login-dropdown').removeClass 'open' ; Router.go 'profile'
            'click #menu-settings': -> $('#login-dropdown').removeClass 'open' ; Router.go 'help'
            'click #menu-change-password': (event) ->
                event.stopPropagation()
                resetMessages()
                Session.set 'login.inChangePasswordFlow', true
                Meteor.flush()

    change_password:
#        jade: (C,_) -> _.slice """each fields|>+form|<br|+login_messages ~
#            |#dropdown-menu-buttons   |>each buttons|>+button ~
#            |<<#dropdown-other-options|>each links  |>+a"""
        jade: 
            'each fields':'+form':''
            br:''
            '+login_messages':''
            '#dropdown-menu-buttons': 'each buttons':'+button':''
            '#dropdown-other-options':'each links':  '+a':''
        events:
            'keypress #old-password, keypress #password, keypress #password-again': (event) -> 
                changePassword() if event.keyCode == 13
            'click #login-buttons-change-password': (event) -> 
                event.stopPropagation(); changePassword()
            'click #login-buttons-back-to-menu': (event) -> 
                event.stopPropagation()
                Session.set 'login.inChangePasswordFlow', false
                $('#login-dropdown').removeClass 'open'
        helpers:
            buttons: -> [ label: 'Change password',   id:'login-buttons-change-password', type:'button' ]
            links:   -> [ label: 'Close',   id:'login-buttons-back-to-menu', class:'dropdown-menu-link', visible: true ]            
            fields:  -> [
                { id: 'old-password',   label: 'Current Password', icon: 'key',      type: 'password' },
                { id: 'password',       label: 'New Password',     icon: 'asterisk', type: 'password' },
                { id: 'password-again', label: 'New Password (again)',               type: 'password', visible: false }]
                        
    dropdown_logged_out:
        styl$: """
            .dropdown-menu
                top 50px
                margin 0px
                font-weight 200
                text-align left
                line-height 14px
                border-radius 0px
            .dropdown-menu-icon
                margin-right 12px
            #dropdown-menu-buttons
                text-align center
            #dropdown-other-options
                padding-top 8px
                line-height 25px
            """
        jade: """
            li.dropdown#login-dropdown
                a.dropdown-toggle(data-toggle="dropdown")
                    | Sign In
                    i.fa.fa-chevron-down
                .dropdown-menu
                    each fields
                        +form
                    br
                    +login_messages
                    #dropdown-menu-buttons
                        each buttons
                            +button
                    #dropdown-other-options
                        each links
                            +a
            """
        helpers:
            links: -> [
                    label: 'Forgot password?', id:'forgot-password-link', class:'dropdown-menu-link', visible: -> loginFlow()
                ,   
                    label: 'Create account',   id:'signup-link',          class:'dropdown-menu-link', visible: -> loginFlow()
                ,   label: 'Back to login',    id:'back-to-login-link',   class:'dropdown-menu-link', visible: -> ! loginFlow() ]
            buttons: -> [
                    label: 'Reset Password',   id:'login-buttons-forgot-password', type:'button',     visible: -> Session.get 'login.inForgotPasswordFlow'                    
                ,
                    label: 'Sign up',          id:'login-buttons-signup',        type:'button',     visible: -> Session.get 'login.inSignupFlow'
                ,   label: 'Sign in',          id:'login-buttons-login',        type:'button',     visible: -> loginFlow() ]                
            fields: -> 
                return if Session.get 'login.inSignupFlow' then [
                    label: 'Username',          icon: 'user'
                ,
                    label: 'Email',             icon: 'envelope-o',       type: 'email'
                ,   label: 'Password',          icon: 'key',              type: 'password'
                ,   
                    label: 'Password again',    icon: 'key',              type: 'password',      visible: -> false ]
                else if Session.get 'login.inForgotPasswordFlow' then [ 
                    label: 'Email',             icon: 'envelope-o',       type: 'email',         id:'forgot-password-email' ]
                else [
                    label: 'Username or email', icon: 'user'
                ,
                    label: 'Username',          icon: 'user',                                    visible: -> false
                ,   
                    label: 'Email',             icon: 'envelope-o',       type: 'email',         visible: -> false
                ,   label: 'Password',          icon: 'key',              type: 'password' ]
        events:
            'click #login-buttons-signup': -> signup()
            'click #login-buttons-login': -> login()
            'keypress #username, keypress #email, keypress #username-or-email, keypress #password, keypress #password-again': (event) ->
                ( if Session.get 'login.inSignupFlow' then signup() else login() ) if event.keyCode == 13
            'keypress #forgot-password-email': (event) -> forgotPassword() if event.keyCode == 13
            'click #login-buttons-forgot-password': (event) -> 
                event.stopPropagation()
                forgotPassword()
            'click #signup-link': (event) -> 
                event.stopPropagation()
                resetMessages()
                username = x.trimmedValue 'username'
                email    = x.trimmedValue 'email'
                usernameOrEmail = x.trimmedValue 'username-or-email'
                password = x.getValue 'password'
                Session.set 'login.inSignupFlow', true
                Session.set 'login.inForgotPasswordFlow', false
                Meteor.flush();
            'click #forgot-password-link': ( event ) ->
                event.stopPropagation()
                resetMessages()
                email = x.trimmedValue 'email'
                usernameOrEmail = x.trimmedValue 'username-or-email'
                Session.set('login.inSignupFlow', false)
                Session.set('login.inForgotPasswordFlow', true);
                Meteor.flush()
            'click #back-to-login-link': ->
                event.stopPropagation()
                resetMessages()
                username = x.trimmedValue 'username'
                email    = x.trimmedValue('email') || x.trimmedValue('forgot-password-email')
                Session.set 'login.inSignupFlow', false
                Session.set 'login.inForgotPasswordFlow', false
                Meteor.flush()
                    
    login_messages:
        styl$: '#login-dropdown .alert':padding:6, marginBottom:14
        jade: 
            '+alert(class="alert-danger"  message=error_message)': ''
            '+alert(class="alert-success" message=info_message )': ''
        helpers:
            error_message: -> Session.get 'login.errorMessage'
            info_message:  -> Session.get 'login.infoMessage'


#        styl$: (C,_) -> _.slice "#login-dropdown .alert|>padding 6px|margin-bottom 14px"
