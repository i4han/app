resetMessages = ->
    Session.set 'login.errorMessage', null
    Session.set 'login.infoMessage', null
    
closeDropdown = ->
    ('inSignupFlow inForgotPasswordFlow inChangePasswordFlow inMessageOnlyFlow dropdownVisible'.split ' ').forEach (key) ->
        Session.set 'login.' + key , false
    resetMessages()
orTest = -> (array) ->
    array.forEach (key) -> 
        return true if Session.get key 
    return false
ensureMessageVisible = ->
    if ! orTest 'resetPasswordToken enrollAccountToken justVerifiedEmail'.split ' '
        Session.set 'dropdownVisible', true

errorMessage = -> (message) ->
    Session.set "login.errorMessage", message
    Session.set "login.infoMessage", null
    ensureMessageVisible()
 
login = ->
    resetMessages();
    username = __.getValue('username');
    email = __.getValue('email');
    usernameOrEmail = __.trim(__.getValue('username-or-email'));
    password = __.getValue('password');
    loginSelector = null
    loginSelector = username: username if username?
    loginSelector = email: email if email?
    loginSelector = usernameOrEmail;
    Meteor.loginWithPassword loginSelector, password, (error, result) ->
        if error then errorMessage error.reason || "Unknown error" else closeDropdown()


module.exports.accounts =

    __events__:
        startup: ->
            if Login._verifyEmailToken
                Login.verifyEmail Login._verifyEmailToken, ( error ) ->
                    Login._enableAutoLogin()
                    Session.set 'login.justVerifiedEmail', true if !error


    _loginButtonsLoggedInDropdown:
        jade: """
            li.dropdown#login-dropdown-list
                a.dropdown-toggle#login-id(data-toggle="dropdown") {{displayName}}
                    i.fa(class="fa-chevron-down")
                if inMessageOnlyFlow
                    .dropdown-menu
                        +_loginButtonsMessages
                else if inChangePasswordFlow
                    .dropdown-menu
                        +_loginButtonsChangePassword
                else
                    .dropdown-menu#logged-in-dropdown
                        +_loginButtonsLoggedInDropdownActions
            """
        styl_compile: (Config) -> """
            #login-dropdown-list
            #login-dropdown-list input
            #login-dropdown-list input:first-of-type
            #login-dropdown-list input:last-of-type
                margin-bottom 0px
                border-top-left-radius 0px
                border-top-right-radius 5px
                border-bottom-left-radius 0px
                border-bottom-right-radius 5px
            #login-dropdown-list
              .dropdown-menu
                width #{Config.$.navbar.login.dropdown.width}
                padding #{Config.$.navbar.login.dropdown.padding}
            """
        events:
            'click #login-buttons-change-password': ( event ) ->
                event.stopPropagation()
                resetMessages()
                Session.set 'login.inChangePasswordFlow', true
                Meteor.flush()
        helpers:
            displayName: -> Login.loginButtons.displayName()
            inChangePasswordFlow: -> Session.get 'login.inChangePasswordFlow'
            inMessageOnlyFlow: -> Session.get 'login.inMessageOnlyFlow'
            dropdownVisible: -> Session.get 'login.dropdownVisible'         
            
            
    _loginButtonsLoggedOut:
        jade: """
            if services
                if configurationLoaded
                    if dropdown
                        +_loginButtonsLoggedOutDropdown
                    else
                        with singleService
                            .login-buttons-with-only-one-button
                                if loggingIn
                                    +_loginButtonsLoggingInSingleLoginButton
                                else
                                    +_loginButtonsLoggedOutSingleLoginButton
            else
                .no-services No login services configured
            """
        helpers:
            dropdown: -> Login.loginButtons.dropdown()        
            services: -> Login.loginButtons.getLoginServices()
            singleService: -> 
                services = Login.loginButtons.getLoginServices()
                throw new Error "Shouldn't be rendering this template with more than one configured service" if services.length != 1
                services[0]
            configurationLoaded: -> Accounts.loginServicesConfigured()            
            
            
    _loginButtonsLoggedIn:
        jade: """
            if dropdown
                +_loginButtonsLoggedInDropdown
            else
                .login-buttons-with-only-one-button
                    +_loginButtonsLoggedInSingleLogoutButton
            """
        helpers: 
            dropdown: -> Login.loginButtons.dropdown()      # of cause
            displayName: -> Login.loginButtons.displayName()
            
            
            
    _loginButtonsLoggedOutPasswordService:
        styl_compile: """
            #login-other-options
                padding-top 8px
            .dropdown-menu-link
                line-height 25px
            """
        jade: """
            if inForgotPasswordFlow
                +_forgotPasswordForm
            else
                each fields
                    +formField
                +_loginButtonsMessages
                button.btn.btn-primary#login-buttons-password(type="button")
                    if inSignupFlow
                        | Create
                    else
                        | Sign in
                if inLoginFlow
                    #login-other-options
                        if showForgotPasswordLink
                            a.dropdown-menu-link#forgot-password-link Forgot password?
                        if showCreateAccountLink
                            a.dropdown-menu-link#signup-link Create account
                else
                    +_loginButtonsBackToLoginLink
            """
        helpers:
            inLoginFlow: -> ! Session.get('login.inSignupFlow')  and ! Session.get 'login.inForgotPasswordFlow'
            inSignupFlow: -> Session.get 'login.inSignupFlow'
            inForgotPasswordFlow: -> Session.get 'login.inForgotPasswordFlow'
            showCreateAccountLink: -> !Accounts._options.forbidClientAccountCreation
            showForgotPasswordLink: -> 
                _.contains ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "EMAIL_ONLY"], Login.ui._passwordSignupFields()
            fields: ->
                loginFields = [
                    label: 'Username or email', icon: 'user',                                    visible: -> _.contains( 
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL"], Login.ui._passwordSignupFields() )
                ,
                    label: 'Username',          icon: 'user'
                    visible: -> Login.ui._passwordSignupFields() == "USERNAME_ONLY"
                ,
                    label: 'Email',             icon: 'envelope-o',       type: 'email'
                    visible: -> Login.ui._passwordSignupFields() == "EMAIL_ONLY"
                , 
                    label: 'Password',          icon: 'key',              type: 'password' ] 
                signupFields = [
                    label: 'Username',          icon: 'user',                                    visible: -> _.contains(
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Login.ui._passwordSignupFields() )
                ,
                    label: 'Email',             icon: 'envelope-o',       type: 'email',         visible: -> _.contains(
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "EMAIL_ONLY"], Login.ui._passwordSignupFields() )
                ,
                    name: 'email'
                    label: 'Email (optional)',  icon: 'envelope-o',       type: 'email',         visible: -> 
                        Login.ui._passwordSignupFields() == "USERNAME_AND_OPTIONAL_EMAIL"
                ,
                    label: 'Password',          icon: 'key',              type: 'password'
                ,
                    label: 'Password again',    icon: 'key',              type: 'password',      visible: -> _.contains(
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Login.ui._passwordSignupFields() ) ]
                signupFields = Login.ui._options.extraSignupFields.concat signupFields
                if Session.get '.login.inSignupFlow' then signupFields else loginFields

                    
    _loginButtonsLoggedOutDropdown:
        jade: """
            li.dropdown#login-dropdown-list
                a.dropdown-toggle(data-toggle="dropdown")
                    | Sign In
                    i.fa.fa-chevron-down
                .dropdown-menu
                    +_loginButtonsLoggedOutAllServices
            """
        helpers:
            additionalClasses: ->
                if !Login.password then false
                else if Session.get 'login.inSignupFlow' then 'login-form-create-account'
                else if Session.get 'login.inForgotPasswordFlow' then 'login-form-forgot-password'
                else 'login-form-sign-in'
            dropdownVisible: -> Session.get 'login.dropdownVisible'
            hasPasswordService: -> Login.loginButtons.hasPasswordService()
            forbidClientAccountCreation: -> Accounts._options.forbidClientAccountCreation # useless
        events:
            'click #login-buttons-password': -> if Session.get 'inSignupFlow' then Signup() else login()
            'keypress #username, keypress #email, keypress #username-or-email, keypress #password, keypress #password-again': ( event ) ->
                ( if Session.get 'inSignupFlow' then Signup() else login() ) if event.keyCode == 13

            'keypress #forgot-password-email': ( event ) -> Login.ui.forgotPassword() if event.keyCode == 13
            'click #login-buttons-forgot-password': ( event ) -> event.stopPropagation() ; Login.ui.forgotPassword()
            'click #signup-link': ( event ) -> 
                event.stopPropagation()
                resetMessages()
                username = __.trimmedValue 'username'
                email = __.trimmedValue 'email'
                usernameOrEmail = __.trimmedValue 'username-or-email'
                password = __.getValue 'password'
                Session.set 'login.inSignupFlow', true
                Session.set 'login.inForgotPasswordFlow', false
                Meteor.flush();
                if username != null
                    document.getElementById('username').value = username
                else if email != null
                    document.getElementById('email').value = email
                else if usernameOrEmail != null and usernameOrEmail.indexOf('@') == -1
                    document.getElementById('username').value = usernameOrEmail
                else
                    document.getElementById('email').value = usernameOrEmail
            'click #forgot-password-link': ( event ) ->
                event.stopPropagation()
                resetMessages()
                email = __.trimmedValue 'email'
                usernameOrEmail = __.trimmedValue 'username-or-email'
                Session.set('login.inSignupFlow', false)
                Session.set('login.inForgotPasswordFlow', true);
                Meteor.flush()
                if email != null
                    document.getElementById('forgot-password-email').value = email
                else if usernameOrEmail != null
                    if usernameOrEmail.indexOf('@') != -1
                        document.getElementById('forgot-password-email').value = usernameOrEmail
            'click #back-to-login-link': ->
                resetMessages()
                username = __.trimmedValue 'username'
                email = __.trimmedValue('email') || __.trimmedValue('forgot-password-email')
                Session.set 'login.inSignupFlow', false
                Session.set 'login.inForgotPasswordFlow', false
                Meteor.flush()
                document.getElementById('username').value = username if document.getElementById 'username'
                document.getElementById('email').value = email if document.getElementById 'email'
                document.getElementById('username-or-email').value = email || username if document.getElementById 'username-or-email'            
            
    _loginButtonsLoggedOutAllServices: # dropdown-menu
        jade: """
            each services
                unless hasPasswordService
                    +_loginButtonsMessages
                if isPasswordService
                    if hasOtherServices
                        +_loginButtonsLoggedOutPasswordServiceSeparator
                    +_loginButtonsLoggedOutPasswordService
                else
                    +_loginButtonsLoggedOutSingleLoginButton
            """
        helpers:
            services: -> Login.loginButtons.getLoginServices()
            isPasswordService: -> this.name == 'password'
            hasOtherServices: -> Login.loginButtons.getLoginServices().length > 1
            hasPasswordService: -> Login.loginButtons.hasPasswordService()
            
            
            
            
    _loginButtonsLoggedInDropdownActions:
        styl_compile: (Config) -> """
            .dropdown-menu a
                display block
                padding 5px 8px
                height #{Config.$.navbar.login.dropdown.a.height}
            .dropdown-menu a:hover
                cursor pointer
                background-color: #{Config.$.navbar.login.dropdown.a.hover.background_color}
            """
        jade: """
            li: a#login-buttons-profile
                i.fa.dropdown-menu-icon.fa-list-alt 
                | Profile
            li: a#login-buttons-settings
                i.fa.dropdown-menu-icon.fa-cog
                | Settings
            li: a#login-buttons-change-password
                i.fa.dropdown-menu-icon.fa-key
                | Change Password
            li.divider
            li: a#login-buttons-logout
                i.fa.dropdown-menu-icon.fa-sign-out
                | Sign Out
            """
        helpers:
            allowChangingPassword: -> 
                user = Meteor.user()
                user.username || ( user.emails && user.emails[0] && user.emails[0].address )
            additionalLoggedInDropdownActions: -> T._loginButtonsAdditionalLoggedInDropdownActions != undefined

            
    _loginButtonsMessages:
        styl_compile: """
            #login-dropdown-list > .alert
                margin 0 0 10px 0
                padding 5px 10px
            """
        jade: """
            if errorMessage
                .alert.alert-danger {{errorMessage}}
            if infoMessage
                .alert.alert-success.no-margin {{infoMessage}}
            """
        helpers:
            errorMessage: -> Session.get 'login.errorMessage'
            infoMessage: -> Session.get 'login.infoMessage'


    _loginButtonsLoggedOutSingleLoginButton:
        jade: """
            .login-text-and-button
                .login-button.single-login-button(class="{{#if configured}}btn btn-info {{else}}configure-button btn btn-danger{{/if}}", id="login-buttons-{{name}}")
                    .login-image(id="login-buttons-image-{{name}}")
                        if configured
                            span.text-besides-image(class="sign-in-text-{{name}}") Sign in with {{capitalizedName}}
                        else
                            span.text-besides-image(class="configure-text-{{name}}") Configure {{capitalizedName}} Login
            """
        helpers:
            configured: -> !!Login.loginServiceConfiguration.findOne service: this.name
            capitalizedName: -> if this.name == 'github' then 'GitHub' else _.str.capitalize this.name
        events:
            'click .login-button': ->
                serviceName = this.name
                resetMessages()
                callback = ( err ) ->
                    if !err
                        closeDropdown()
                    else if err instanceof Login.LoginCancelledError
                        0
                    else if err instanceof Login.ConfigError
                        __.configureService serviceName
                    else
                        __.errorMessage err.reason || "Unknown error"
                loginWithService = Meteor[ "loginWith" + _.str.capitalize serviceName ]
                options = {}
                if Login.ui._options.requestPermissions[ serviceName ]
                    options.requestPermissions = Login.ui._options.requestPermissions[ serviceName ]
                loginWithService options, callback

                
                
    _loginButtonsMessagesDialog:
        jade: """
            if visible
                .accounts-dialog.accounts-centered-dialog#login-buttons-message-dialog
                    +_loginButtonsMessages
                    .login-button#messages-dialog-dismiss-button Dismiss
            """
        events:
            'click #messages-dialog-dismiss-button': -> resetMessages()
        visible: -> !Login.loginButtons.dropdown() && ( Session.get('login.infoMessage') || Session.get('login.errorMessage') )

        
        
    _justVerifiedEmailDialog:        
        jade: """
            if visible
                .accounts-dialog.accounts-centered-dialog
                    | Email verified
                    .login-button#just-verified-dismiss-button Dismiss
            """
        events:
            'click #just-verified-dismiss-button': -> Session.set('login.justVerifiedEmail', false)
        visible: -> Session.get('login.justVerifiedEmail')

        
        
        
    _loginButtonsLoggingInPadding:
        jade: """
            unless dropdown
                .login-buttons-padding
                    .login-button.single-login-button#login-buttons-logout(style="visibility: hidden;") &nbsp;
            else
                .login-buttons-padding
            """
        dropdown: -> Login.loginButtons.dropdown()


    loginButtons: # style_compile
        styl_compile: """
            #login-buttons
                float right
                border 0
            .login-buttons-dropdown-align-left
              &#login-buttons + li
                .dropdown-menu
                  float: left;
                  left: 0;
                  right: auto;
            .login-buttons-dropdown-align-right
              &#login-buttons + li
                .dropdown-menu
                  float: right;
                  right: 0;
                  left: auto;

            """
        jade: """
            ul.nav.navbar-nav.login-buttons-dropdown-align-right#login-buttons
                if currentUser
                    if loggingIn
                        if dropdown 
                            +_loginButtonsLoggingIn
                        else
                            .login-buttons-with-only-one-button
                                +_loginButtonsLoggingInSingleLoginButton
                    else
                        +_loginButtonsLoggedIn
                else
                    +_loginButtonsLoggedOut        
            """
        events:
            'click #login-buttons-logout': -> Meteor.logout -> closeDropdown() ; Router.go 'home'
            'click #login-buttons-profile': -> $('#login-dropdown-list').removeClass 'open' ; Router.go 'profile'
            'click #login-buttons-settings': -> $('#login-dropdown-list').removeClass 'open' ; Router.go 'settings'
            'click input, click label, click button, click .dropdown-menu, click .alert': ( event ) -> event.stopPropagation()
            'click .login-close': -> closeDropdown() ; $('#login-dropdown-list').removeClass 'open' ; console.log "login-close"
            'click #login-name-link, click #login-sign-in-link': ( event ) -> 
                event.stopPropagation()
                Session.set 'login.dropdownVisible', true
                Meteor.flush()
        toggleDropdown: -> $('#login-dropdown-list .dropdown-menu').dropdown 'toggle'  # not used


                
    _loginButtonsChangePassword:
        jade: """
            each fields
                +formField
            +_loginButtonsMessages
            button.btn.btn-primary#login-buttons-do-change-password Change password
            button.btn.btn-default.login-close#login-button-back-to-menu Close
            """
        events:
            'keypress #old-password, keypress #password, keypress #password-again': ( event ) -> Login.ui.changePassword() if event.keyCode == 13
            'click #login-buttons-do-change-password': ( event ) -> event.stopPropagation(); Login.ui.changePassword()
            'click #login-buttons-back-to-menu': ( event ) -> event.stopPropagation(); $('#login-dropdown-list').removeClass 'open'
        fields: -> [
            name: 'old-password'
            label: 'Current Password', icon: 'key',           type: 'password'
        ,
            name: 'password'
            label: 'New Password',     icon: 'asterisk',      type: 'password'
        ,
            name: 'password-again'
            label: 'New Password (again)',                    type: 'password',           visible: -> 
                _.contains( ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Login.ui._passwordSignupFields() ) ]


    _loginButtonsBackToLoginLink:
        jade: """
            button.btn.btn-default#back-to-login-link Back to sign in
            """

    _forgotPasswordForm:
        styl_compile: """
            .input-group
                width 100%            
            .input-group-addon
                width 27px
                padding-left 4px
                padding-right 4px
            """
        jade: """
            .login-form
                .forgot-password-email-label-and-input 
                    .input-group.margin-bottom-sm
                        span.input-group-addon: i.fa.fa-envelope-o.fa-fw
                        input.form-control#forgot-password-email(type="email" placeholder="E-mail")
                +_loginButtonsMessages
                button.btn.btn-primary.login-button-form-submit#login-buttons-forgot-password Reset Password
                +_loginButtonsBackToLoginLink
            """

    _loginButtonsLoggedInSingleLogoutButton:
        jade: """
            .login-text-and-button: .login-display-name {{displayName}}
            .login-button.single-login-button#login-buttons-logout Sign Out
            """

    _loginButtonsLoggingIn:
        jade: """
            +_loginButtonsLoggingInPadding
            .loading &nbsp;
            +_loginButtonsLoggingInPadding
            """
    
    _loginButtonsLoggingInSingleLoginButton:
        jade: """
            .login-text-and-button
                +_loginButtonsLoggingIn
            """

    _loginButtonsLoggedOutPasswordServiceSeparator:
        jade: """
            .or
                span.hline &nbsp; &nbsp; &nbsp;
                span.or-text or
                span.hline &nbsp; &nbsp; &nbsp;
            """
    _resetPasswordDialog:
        jade: """
            if inResetPasswordFlow
                .modal#login-buttons-reset-password-modal: .modal-dialog: .modal-content
                    .modal-header
                        button.close(type="button" data-dismiss="modal" aria-hidden="true") &times;
                        h4.modal-title Reset your password
                    .modal-body
                        input.form-control#reset-password-new-password(type="password" placeholder="New Password")
                        +_loginButtonsMessages
                    .modal-footer
                        a.btn.btn-default#login-buttons-cancel-reset-password Close
                        button.btn.btn-primary#login-buttons-reset-password-button Set password
            """

        events:
            'click #login-buttons-reset-password-button': -> Login.ui.resetPassword()
            'keypress #reset-password-new-password': ( event ) -> Login.ui.resetPassword() if event.keyCode == 13
            'click #login-buttons-cancel-reset-password': ->
                Session.set 'login.resetPasswordToken', null
                Login._enableAutoLogin()
                $('#login-buttons-reset-password-modal').modal 'hide'
        rendered: ->
            $modal = $(this.find '#login-buttons-reset-password-modal' )
            $modal.modal()
        inResetPasswordFlow: -> Session.get('login.resetPasswordToken')
    _enrollAccountDialog:
        jade: """
            if inEnrollAccountFlow
                .modal#login-buttons-enroll-account-modal: .modal-dialog: .modal-content
                    .modal-header
                        button.close(type="button" data-dismiss="modal" aria-hidden="true") &times;
                        h4.modal-title Choose a password
                    .modal-body
                        input.form-control#enroll-account-password(type="password" placeholder="New Password")
                        +_loginButtonsMessages
                    .modal-footer
                        a.btn.btn-default#login-buttons-cancel-enroll-account-button Close
                        button.btn.btn-primary#login-buttons-enroll-account-button Set Password
            """
        events:
            'click #login-buttons-enroll-account-button': -> enrollAccount()
            'keypress #enroll-account-password': ( event ) -> enrollAccount() if event.keyCode == 13
            'click #login-buttons-cancel-enroll-account-button': ->
                Session.set 'login.enrollAccountToken', null
                Accounts._enableAutoLogin()
                $modal.modal "hide"
        rendered: ->
            $modal = $(this.find '#login-buttons-enroll-account-modal' )
            $modal.modal()
        inEnrollAccountFlow: -> Session.get('login.enrollAccountToken')

    __loginStyle:
        styl_compile: """
            .btn
                margin-top 5px
            input
                margin 0px
                border-radius 0px
            input:first-of-type
                margin-top 0px
                border-top-left-radius 5px
                border-top-right-radius 5px
            input:last-of-type
                margin-bottom 5px
                border-bottom-left-radius 5px
                border-bottom-right-radius 5px
            #login-buttons-reset-password-modal, #login-buttons-enroll-account-modal
              .modal-content
                margin-top: 30%;

            .or
              text-align: center

            .dropdown-menu
              top 50px
              margin 0px
              font-weight 200
              text-align left
              line-height 20px
              border-radius 0px

              &#logged-in-dropdown
                right 0
                left auto
                width 186px
                padding-left 0px
                padding-right 0px
                padding-top 5px
                padding-bottom 5px

            .dropdown-menu-icon
              margin-right 12px
            """