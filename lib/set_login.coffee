module.exports.login =

    __events__:
        startup: ->
            console.log 'Start up'
            if Accounts._verifyEmailToken
                Accounts.verifyEmail Accounts._verifyEmailToken, ( error ) ->
                    Accounts._enableAutoLogin()
                    Accounts.loginSession.set 'justVerifiedEmail', true if !error


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
        events:
            'click #login-buttons-change-password': ( event ) ->
                event.stopPropagation()
                Accounts.loginSession.resetMessages()
                Accounts.loginSession.set 'inChangePasswordFlow', true
                Meteor.flush()
        helpers:
            displayName: -> Accounts.loginButtons.displayName()
            inChangePasswordFlow: -> Accounts.loginSession.get('inChangePasswordFlow')
            inMessageOnlyFlow: -> Accounts.loginSession.get('inMessageOnlyFlow')
            dropdownVisible: -> Accounts.loginSession.get('dropdownVisible')            
            
            
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
            dropdown: -> Accounts.loginButtons.dropdown()        
            services: -> Accounts.loginButtons.getLoginServices()
            singleService: -> 
                services = Accounts.loginButtons.getLoginServices()
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
            dropdown: -> Accounts.loginButtons.dropdown()      # of cause
            displayName: -> Accounts.loginButtons.displayName()
            
            
            
    _loginButtonsLoggedOutPasswordService:
        stylus: """
            #login-other-options
                padding-top 8px
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
                        br.single-line
                        if showForgotPasswordLink
                            a.dropdown-menu-link#forgot-password-link Forgot password?
                            br.half-line
                        if showCreateAccountLink
                            a.dropdown-menu-link#signup-link Create account
                else
                    +_loginButtonsBackToLoginLink
            """
        helpers:
            inLoginFlow: -> !Accounts.loginSession.get('inSignupFlow')  and !Accounts.loginSession.get 'inForgotPasswordFlow'
            inSignupFlow: -> Accounts.loginSession.get 'inSignupFlow'
            inForgotPasswordFlow: -> Accounts.loginSession.get 'inForgotPasswordFlow'
            showCreateAccountLink: -> !Accounts._options.forbidClientAccountCreation
            showForgotPasswordLink: -> 
                _.contains ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "EMAIL_ONLY"], Accounts.ui._passwordSignupFields()
            fields: ->
                loginFields = [
                    label: 'Username or email', icon: 'user',                                    visible: -> _.contains( 
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL"], Accounts.ui._passwordSignupFields() )
                ,
                    label: 'Username',          icon: 'user'
                    visible: -> Accounts.ui._passwordSignupFields() == "USERNAME_ONLY"
                ,
                    label: 'Email',             icon: 'envelope-o',       type: 'email'
                    visible: -> Accounts.ui._passwordSignupFields() == "EMAIL_ONLY"
                , 
                    label: 'Password',          icon: 'key',              type: 'password' ] 
                signupFields = [
                    label: 'Username',          icon: 'user',                                    visible: -> _.contains(
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields() )
                ,
                    label: 'Email',             icon: 'envelope-o',       type: 'email',         visible: -> _.contains(
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "EMAIL_ONLY"], Accounts.ui._passwordSignupFields() )
                ,
                    name: 'email'
                    label: 'Email (optional)',  icon: 'envelope-o',       type: 'email',         visible: -> 
                        Accounts.ui._passwordSignupFields() == "USERNAME_AND_OPTIONAL_EMAIL"
                ,
                    label: 'Password',          icon: 'key',              type: 'password'
                ,
                    label: 'Password again',    icon: 'key',              type: 'password',      visible: -> _.contains(
                        ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields() ) ]
                signupFields = Accounts.ui._options.extraSignupFields.concat signupFields
                if Accounts.loginSession.get('inSignupFlow') then signupFields else loginFields

                    
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
                if !Accounts.password then false
                else if Accounts.loginSession.get 'inSignupFlow' then 'login-form-create-account'
                else if Accounts.loginSession.get 'inForgotPasswordFlow' then 'login-form-forgot-password'
                else 'login-form-sign-in'
            dropdownVisible: -> Accounts.loginSession.get 'dropdownVisible'
            hasPasswordService: -> Accounts.loginButtons.hasPasswordService()
            forbidClientAccountCreation: -> Accounts._options.forbidClientAccountCreation # useless
        events:
            'click #login-buttons-password': -> Accounts.ui.loginOrSignup()
            'keypress #forgot-password-email': ( event ) -> Accounts.ui.forgotPassword() if event.keyCode == 13
            'click #login-buttons-forgot-password': ( event ) -> event.stopPropagation() ; Accounts.ui.forgotPassword()
            'click #signup-link': ( event ) -> 
                event.stopPropagation()
                Accounts.loginSession.resetMessages()
                username = __.trimmedValue 'username'
                email = __.trimmedValue 'email'
                usernameOrEmail = __.trimmedValue 'username-or-email'
                password = __.getValue 'password'
                Accounts.loginSession.set 'inSignupFlow', true
                Accounts.loginSession.set 'inForgotPasswordFlow', false
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
                Accounts.loginSession.resetMessages()
                email = __.trimmedValue 'email'
                usernameOrEmail = __.trimmedValue 'username-or-email'
                Accounts.loginSession.set('inSignupFlow', false)
                Accounts.loginSession.set('inForgotPasswordFlow', true);
                Meteor.flush()
                if email != null
                    document.getElementById('forgot-password-email').value = email
                else if usernameOrEmail != null
                    if usernameOrEmail.indexOf('@') != -1
                        document.getElementById('forgot-password-email').value = usernameOrEmail
            'click #back-to-login-link': ->
                Accounts.loginSession.resetMessages()
                username = __.trimmedValue 'username'
                email = __.trimmedValue('email') || __.trimmedValue('forgot-password-email')
                Accounts.loginSession.set 'inSignupFlow', false
                Accounts.loginSession.set 'inForgotPasswordFlow', false
                Meteor.flush()
                document.getElementById('username').value = username if document.getElementById 'username'
                document.getElementById('email').value = email if document.getElementById 'email'
                document.getElementById('username-or-email').value = email || username if document.getElementById 'username-or-email'
            'keypress #username, keypress #email, keypress #username-or-email, keypress #password, keypress #password-again': ( event ) ->
                Accounts.ui.loginOrSignup() if event.keyCode == 13
            
            
    _loginButtonsLoggedOutAllServices:
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
            services: -> Accounts.loginButtons.getLoginServices()
            isPasswordService: -> this.name == 'password'
            hasOtherServices: -> Accounts.loginButtons.getLoginServices().length > 1
            hasPasswordService: -> Accounts.loginButtons.hasPasswordService()
            
            
            
            
    _loginButtonsLoggedInDropdownActions:
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
        stylus: """
            #login-dropdown-list > .alert
                margin 0 0 10px 0
                padding 5px 10px
            """
        jade: """
            br.half-line
            if errorMessage
                .alert.alert-danger {{errorMessage}}
            if infoMessage
                .alert.alert-success.no-margin {{infoMessage}}
            """
        helpers:
            errorMessage: -> Accounts.loginSession.get 'errorMessage'
            infoMessage: -> Accounts.loginSession.get 'infoMessage'


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
            configured: -> !!Accounts.loginServiceConfiguration.findOne service: this.name
            capitalizedName: -> if this.name == 'github' then 'GitHub' else _.str.capitalize this.name
        events:
            'click .login-button': ->
                serviceName = this.name
                __.resetMessages()
                callback = ( err ) ->
                    if !err
                        __.closeDropdown()
                    else if err instanceof Accounts.LoginCancelledError
                        0
                    else if err instanceof Accounts.ConfigError
                        __.configureService serviceName
                    else
                        __.errorMessage err.reason || "Unknown error"
                loginWithService = Meteor[ "loginWith" + _.str.capitalize serviceName ]
                options = {}
                if Accounts.ui._options.requestPermissions[ serviceName ]
                    options.requestPermissions = Accounts.ui._options.requestPermissions[ serviceName ]
                loginWithService options, callback

                
                
    _loginButtonsMessagesDialog:
        jade: """
            if visible
                .accounts-dialog.accounts-centered-dialog#login-buttons-message-dialog
                    +_loginButtonsMessages
                    .login-button#messages-dialog-dismiss-button Dismiss
            """
        events:
            'click #messages-dialog-dismiss-button': -> Accounts.loginSession.resetMessages()
        visible: -> !Accounts.loginButtons.dropdown() && ( Accounts.loginSession.get('infoMessage') || Accounts.loginSession.get('errorMessage') )

        
        
    _justVerifiedEmailDialog:        
        jade: """
            if visible
                .accounts-dialog.accounts-centered-dialog
                    | Email verified
                    .login-button#just-verified-dismiss-button Dismiss
            """
        events:
            'click #just-verified-dismiss-button': -> Accounts.loginSession.set('justVerifiedEmail', false)
        visible: -> Accounts.loginSession.get('justVerifiedEmail')

        
        
        
    _loginButtonsLoggingInPadding:
        jade: """
            unless dropdown
                .login-buttons-padding
                    .login-button.single-login-button#login-buttons-logout(style="visibility: hidden;") &nbsp;
            else
                .login-buttons-padding
            """
        dropdown: -> Accounts.loginButtons.dropdown()


    loginButtons:
        stylus: """
            #login-buttons
                line-height 15px
                float right
                border 0
                padding 0
                height 50px
                width 80px
            """
        jade: """
            .login-buttons-dropdown-align-right#login-buttons
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
            'click #login-buttons-logout': -> Meteor.logout -> Accounts.loginSession.closeDropdown() ; Router.go 'home'
            'click #login-buttons-profile': -> $('#login-dropdown-list').removeClass 'open' ; Router.go 'profile'
            'click #login-buttons-settings': -> $('#login-dropdown-list').removeClass 'open' ; Router.go 'settings'
            'click input, click label, click button, click .dropdown-menu, click .alert': ( event ) -> event.stopPropagation()
            'click .login-close': -> Accounts.loginSession.closeDropdown() ; $('#login-dropdown-list').removeClass 'open' ; console.log "login-close"
            'click #login-name-link, click #login-sign-in-link': ( event ) -> 
                event.stopPropagation()
                Accounts.loginSession.set 'dropdownVisible', true
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
            'keypress #old-password, keypress #password, keypress #password-again': ( event ) -> Accounts.ui.changePassword() if event.keyCode == 13
            'click #login-buttons-do-change-password': ( event ) -> event.stopPropagation(); Accounts.ui.changePassword()
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
                _.contains( ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields() ) ]


    _loginButtonsBackToLoginLink:
        jade: """
            button.btn.btn-default#back-to-login-link Back to sign in
            """

    _forgotPasswordForm:
        stylus: """
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
    loginStyle:
        stylus: """
            .dropdown-menu > li > a
                display: block;
                padding: 5px 8px;
            #login-dropdown-list
              .dropdown-menu
                width 208px
                padding 5px 8px
            #forgot-password-link
            #signup-link
                margin-top 10px
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
            """