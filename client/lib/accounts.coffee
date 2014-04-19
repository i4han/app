Accounts.loginSession = 
    set: ( key, value ) ->
        #validateKey key
        if _.contains ['errorMessage', 'infoMessage'], key
            throw new Error "Don't set errorMessage or infoMessage directly. Instead, use errorMessage() or infoMessage()."
        this._set( key, value )      
    _set: ( key, value ) -> Session.set( "Meteor.loginButtons." + key, value)
    get: ( key ) -> #validateKey key ; 
        Session.get 'Meteor.loginButtons.' + key 
    closeDropdown: ->
        this.set 'inSignupFlow', false
        this.set 'inForgotPasswordFlow', false
        this.set 'inChangePasswordFlow', false
        this.set 'inMessageOnlyFlow', false
        this.set 'dropdownVisible', false
        this.resetMessages
    infoMessage: ( message ) ->
        this._set "errorMessage", null
        this._set "infoMessage", message
        this.ensureMessageVisible
    errorMessage: ( message ) ->
        this._set "errorMessage", message
        this._set "infoMessage", null
        this.ensureMessageVisible
    isMessageDialogVisible: -> this.get('resetPasswordToken') || this.get('enrollAccountToken') || this.get('justVerifiedEmail')
    ensureMessageVisible: -> this.set "dropdownVisible", true if !this.isMessageDialogVisible
    resetMessages: ->
        this._set "errorMessage", null
        this._set "infoMessage", null
    configureService: (name) -> 
        this.set 'configureLoginServiceDialogVisible', true
        this.set 'configureLoginServiceDialogServiceName', name
        this.set 'configureLoginServiceDialogSaveDisabled', true


Accounts.loginSession.set 'resetPasswordToken', Accounts._resetPasswordToken if Accounts._resetPasswordToken
Accounts.loginSession.set 'enrollAccountToken', Accounts._enrollAccountToken if Accounts._enrollAccountToken
        
Accounts.loginButtons = {} if !Accounts.loginButtons
Accounts.loginButtons.displayName = ->
    user = Meteor.user()
    if !user then '' 
    else if user.profile && user.profile.name then user.profile.name
    else if user.username then user.username
    else if user.emails && user.emails[0] && user.emails[0].address then user.emails[0].address  
    else ''
Accounts.loginButtons.getLoginServices = ->
    services = if Package['accounts-oauth'] then Accounts.oauth.serviceNames() else []
    services.sort()
    services.push 'password' if this.hasPasswordService()
    _.map services, ( name ) -> name: name
Accounts.loginButtons.hasPasswordService = -> !!Package['accounts-password']  
Accounts.loginButtons.dropdown = -> this.hasPasswordService() || Accounts.loginButtons.getLoginServices().length > 1
Accounts.loginButtons.validateUsername = ( username ) ->
    if username.length >= 3 then true else Accounts.loginSession.errorMessage "Username must be at least 3 characters long" && false
Accounts.loginButtons.validateEmail = ( email ) -> 
    return true if Accounts.ui._passwordSignupFields() == "USERNAME_AND_OPTIONAL_EMAIL" && email == ''
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    if re.test email then true else Accounts.loginSession.errorMessage "Invalid email" && false
Accounts.loginButtons.validatePassword = ( password ) ->
    if password.length >= 6 then true else Accounts.loginSession.errorMessage "Password must be at least 6 characters long" &&  false
Accounts.loginButtons.rendered = -> debugger
        

        
Accounts.ui =
    _options: 
        requestPermissions: {}
        extraSignupFields: []
    navigate: ( route, hash ) -> Router.go route, hash
    _passwordSignupFields: -> Accounts.ui._options.passwordSignupFields || 'USERNAME_AND_EMAIL'
    config: ( options ) ->
        _.each _.keys( options ), ( key ) ->
            if !_.contains ['passwordSignupFields', 'requestPermissions', 'extraSignupFields'], key
                throw new Error "Accounts.ui.config: Invalid key: " + key 
        if options.passwordSignupFields
            if _.contains [
                'USERNAME_AND_EMAIL_CONFIRM'
                'USERNAME_AND_EMAIL'
                'USERNAME_AND_OPTIONAL_EMAIL'
                'USERNAME_ONLY'
                'EMAIL_ONLY'
            ], options.passwordSignupFields
                if Accounts.ui._options.passwordSignupFields
                    throw new Error "Accounts.ui.config: Can't set `passwordSignupFields` more than once"
                else
                    Accounts.ui._options.passwordSignupFields = options.passwordSignupFields
            else
                throw new Error 'Accounts.ui.config: Invalid option for `passwordSignupFields`: ' + options.passwordSignupFields
    
        if options.requestPermissions
            _.each options.requestPermissions, ( scope, service ) ->
                if Accounts.ui._options.requestPermissions[ service ]
                    throw new Error "Accounts.ui.config: Can't set `requestPermissions` more than once for " + service
                else if !(scope instanceof Array)
                    throw new Error 'Accounts.ui.config: Value for `requestPermissions` must be an array'
                else
                    Accounts.ui._options.requestPermissions[ service ] = scope
            if typeof options.extraSignupFields != 'object' || !options.extraSignupFields instanceof Array
                throw new Error 'Accounts.ui.config: `extraSignupFields` must be an array.'
            else
                if options.extraSignupFields
                    _.each options.extraSignupFields, ( field, index ) ->
                        if !field.fieldName || !field.fieldLabel
                            throw new Error 'Accounts.ui.config: `extraSignupFields` objects must have `fieldName` and `fieldLabel` attributes.'
                        if typeof field.visible == 'undefined'
                            field.visible = true
                        Accounts.ui._options.extraSignupFields[ index ] = field

    changePassword: ->
        Accounts.loginSession.resetMessages()
        oldPassword = __.getValue 'old-password'
        password = __.getValue 'password'
        return if !Accounts.loginButtons.validatePassword password || !Accounts.ui.matchPasswordAgainIfPresent()
        Accounts.changePassword oldPassword, password, ( error ) ->
            if error
                Accounts.loginSession.errorMessage error.reason || "Unknown error" 
            else 
                Accounts.loginSession.infoMessage "Password changed"
                Meteor.setTimeout( -> 
                    Accounts.loginSession.resetMessages() 
                    Accounts.loginSession.closeDropdown()
                    $('#login-dropdown-list').removeClass 'open'
                , 3000 )
            

    matchPasswordAgainIfPresent: ->
        passwordAgain = __.getValue 'password-again'
        if passwordAgain != null
            password = __.getValue 'password'
            if password != passwordAgain
                Accounts.loginSession.errorMessage "Passwords don't match"
                return false
        true

    resetPassword: ->
        Accounts.loginSession.resetMessages()
        newPassword = document.getElementById('reset-password-new-password').value
        return if !Accounts.loginButtons.validatePassword newPassword
        Accounts.resetPassword Accounts.loginSession.get('resetPasswordToken'), newPassword, ( error ) ->
            if error
                Accounts.loginSession.errorMessage error.reason || "Unknown error"
            else
                Accounts.loginSession.set 'resetPasswordToken', null
                Accounts._enableAutoLogin()
                $('#login-buttons-reset-password-modal').modal "hide"

    enrollAccount: ->
        Accounts.loginSession.resetMessages()
        password = document.getElementById('enroll-account-password').value
        return if !Accounts.loginButtons.validatePassword password
        Accounts.resetPassword Accounts.loginSession.get('enrollAccountToken'), password, ( error ) ->
            if error
                Accounts.loginSession.errorMessage error.reason || "Unknown error"
            else
                Accounts.loginSession.set 'enrollAccountToken', null
                Accounts._enableAutoLogin()
                $modal.modal "hide"
                
    login: -> 
        Accounts.loginSession.resetMessages()
        username = __.getValue 'username'
        email = __.getValue 'email'
        usernameOrEmail = __.trim __.getValue 'username-or-email'
        password = __.getValue 'password'
        loginSelector = undefined
        if username != null
            if !Accounts.loginButtons.validateUsername username
                return
            else
                loginSelector = username: username
        else if email != null
            if !Accounts.loginButtons.validateEmail email
                return
            else
                loginSelector = email: email
        else if usernameOrEmail != null
            if !Accounts.loginButtons.validateUsername usernameOrEmail
                return
            else
                loginSelector = usernameOrEmail
        else
            throw new Error "Unexpected -- no element to use as a login user selector"
        Meteor.loginWithPassword loginSelector, password, ( error, result ) -> 
            if error then Accounts.loginSession.errorMessage( error.reason || "Unknown error" ) else Accounts.loginSession.closeDropdown()

    signup: -> 
        Accounts.loginSession.resetMessages()
        options = {}
        username = __.trimmedValue 'username'
        if username != null
            if !Accounts.loginButtons.validateUsername username
                return
            else
                options.username = username
        email = __.trimmedValue 'email'
        if email != null
            if !Accounts.loginButtons.validateEmail email
                return
            else
                options.email = email
        password = __.getValue 'password'
        if !Accounts.loginButtons.validatePassword password
            return
        else
            options.password = password
        return if !Accounts.ui.matchPasswordAgainIfPresent()
        options.profile = {}
        errorFn = ( errorMessage ) -> Accounts.loginSession.errorMessage(errorMessage)
        invalidExtraSignupFields = false
        _.each Accounts.ui._options.extraSignupFields, ( field, index ) ->
            value = __.getValue field.fieldName
            if typeof field.validate == 'function'
                if field.validate value, errorFn
                    options.profile[ field.fieldName ] = __.getValue field.fieldName
                else
                    invalidExtraSignupFields = true
            else
                options.profile[ field.fieldName ] = __.getValue field.fieldName
        return if invalidExtraSignupFields
        Accounts.createUser options, ( error ) ->
            if error then Accounts.loginSession.errorMessage error.reason || "Unknown error" else Accounts.loginSession.closeDropdown()
    forgotPassword: ->
        Accounts.loginSession.resetMessages()
        email = __.trimmedValue "forgot-password-email"
        if email.indexOf('@') != -1
            Accounts.forgotPassword email: email, ( error ) -> 
                if error then Accounts.loginSession.errorMessage error.reason || "Unknown error" else Accounts.loginSession.infoMessage "Email sent"  
        else
            Accounts.loginSession.infoMessage "Email sent"
    matchPasswordAgainIfPresent: ->
        passwordAgain = __.getValue 'password-again'
        if passwordAgain != null
            password = __.getValue 'password'
            if password != passwordAgain
                Accounts.loginSession.errorMessage "Passwords don't match"
                return false
        true
    
    loginOrSignup: -> if Accounts.loginSession.get 'inSignupFlow' then Accounts.ui.signup() else Accounts.ui.login()

    templateForService: ->
        serviceName = Accounts.loginSession.get 'configureLoginServiceDialogServiceName'
        Template[ 'configureLoginServiceDialogFor' + _.str.capitalize serviceName ]      # _.str.capitalize removed.
    configurationFields: ->
        template = Accounts.ui.templateForService()
        template.fields()
