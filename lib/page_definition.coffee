_.define =


    profile:
        template:   """    
            .primary-content    
                .col-sm-4
                .col-sm-6
                    br.double-line
                    each fields
                        +formField
                        br.half-line
                .col-sm-2
                    br    
                    """
        fields: -> [
            title: 'Your name'
            label: 'Name',   icon: 'user'
        ,
            title: 'Mobile Phone Number'
            label: 'Mobile', icon: 'mobile'
        ,
            title: 'Your home Zip code' 
            label: 'Zip',    icon: 'envelope' ]
        events:
            'focus input#name': -> $('input#name').attr('data-content',  T['popover_name'].render().value).popover('show')

            
    help:
        rendered: ->
            container = $('#debug')
            container.append( $("<p>hello</p>") )
            _.each _.keys( _.define ), ( name ) ->
                container.append( $("<h3>#{name}.</h3>") )         
                _.each _.keys( _.define[ name ] ), ( key ) ->
                    container.append( $("<div>#{name} #{key} = #{_.define[name][key]}</div>") ) 
            
            
    loginButtons:
        template:   """
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
                
                
                
    _loginButtonsLoggedInDropdown:
        template:   """
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
        helpers:
            dropdown: -> Accounts.loginButtons.dropdown()        
            services: -> Accounts.loginButtons.getLoginServices()
            singleService: -> 
                services = Accounts.loginButtons.getLoginServices()
                throw new Error "Shouldn't be rendering this template with more than one configured service" if services.length != 1
                services[0]
            configurationLoaded: -> Accounts.loginServicesConfigured()
            
            
            
    _loginButtonsLoggedIn:
        helpers: 
            dropdown: -> Accounts.loginButtons.dropdown()      # of cause
            displayName: -> Accounts.loginButtons.displayName()
            
            
            
    _loginButtonsLoggedOutPasswordService:
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
