Colors = new Meteor.Collection 'colors'
Meteor.subscribe('colors')
Router.configure layoutTemplate: 'layout'
Router.map -> 
    this.route 'home', path: '/'
    this.route 'about' 
    this.route 'help'
    this.route 'profile'
    this.route 'settings'

Accounts.ui.config passwordSignupFields: 'USERNAME_AND_EMAIL'
Template.hello.events 'click input': -> 
    console.log Router.current().route.name
Template.home.rendered = ->
    console.log Router.current().route.name
    if Router.current().route.name == 'home'
        _.each [1..12], (i) -> $('#tile-box').append( $("<div id=\"tile-#{i}\" class=\"tile\"><h2>Tile #{i}</h2></div>") ) 
        $('.tile').on 'scrollSpy:enter', -> console.log 'enter:', $(this).attr 'id' 
        $('.tile').on 'scrollSpy:exit', -> console.log 'exit:', $(this).attr 'id' 
        $('.tile').scrollSpy()
window.onscroll = ( e ) -> console.log window.scrollY
window.onresize = -> console.log window.innerWidth

Template.color_list.colors = -> Colors.find {}, sort: likes: -1, name: 1
Template.color_list.events 'click button': -> Colors.update Session.get( 'session_color' ), $inc: likes: 1 
Template.color_info.events 'click': -> Session.set 'session_color', this._id
Template.color_info.maybe_selected = -> if Session.equals 'session_color', this._id then 'selected' else 'not_selected'

vaild_keys = [
    'dropdownVisible', 'inSignupFlow', 'inForgotPasswordFlow', 'inChangePasswordFlow', 'inMessageOnlyFlow',
    'errorMessage', 'infoMessage', 'resetPasswordToken', 'enrollAccountToken', 'justVerifiedEmail',
    'configureLoginServiceDialogVisible', 'configureLoginServiceDialogServiceName', 'configureLoginServiceDialogSaveDisabled' ]
validateKey = ( key ) ->  throw new Error "Invalid key in loginButtonsSession: " + key if !_.contains vaild_keys, key
__ = Accounts.loginButtonsSession =
    set: ( key, value ) ->
        validateKey key
        if _.contains ['errorMessage', 'infoMessage'], key
            throw new Error "Don't set errorMessage or infoMessage directly. Instead, use errorMessage() or infoMessage()."
        this._set( key, value )      
    _set: ( key, value ) -> Session.set( "Meteor.loginButtons." + key, value)
    get: ( key ) -> validateKey key ; Session.get 'Meteor.loginButtons.' + key 
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
closeMenu = -> $('#login-dropdown-list').removeClass 'open' ; console.log "close Menu"

Accounts.loginButtons = {} if !Accounts.loginButtons
Accounts.loginButtons.displayName = ->
    user = Meteor.user()
    if !user
        ''  
    else if user.profile && user.profile.name
        user.profile.name
    else if user.username
        user.username
    else if user.emails && user.emails[0] && user.emails[0].address
        user.emails[0].address  
    else
        ''
Accounts.loginButtons.getLoginServices = ->
    services = if Package['accounts-oauth'] then Accounts.oauth.serviceNames() else []
    services.sort()
    services.push 'password' if this.hasPasswordService()
    _.map services, ( name ) -> name: name
Accounts.loginButtons.hasPasswordService = -> !!Package['accounts-password']  
Accounts.loginButtons.dropdown = -> this.hasPasswordService() || Accounts.loginButtons.getLoginServices().length > 1
Accounts.loginButtons.validateUsername = ( username ) ->
    if username.length >= 3 then true else __.errorMessage "Username must be at least 3 characters long" && false
Accounts.loginButtons.validateEmail = ( email ) -> 
    return true if Accounts.ui._passwordSignupFields() == "USERNAME_AND_OPTIONAL_EMAIL" && email == ''
    re = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/
    if re.test email then true else __.errorMessage "Invalid email" && false
Accounts.loginButtons.validatePassword = ( password ) ->
    if password.length >= 6 then true else __.errorMessage "Password must be at least 6 characters long" &&  false
Accounts.loginButtons.rendered = -> debugger

Template.loginButtons.events
    'click #login-buttons-logout': -> Meteor.logout -> __.closeDropdown() ; Router.go 'home'
    'click #login-buttons-profile': -> closeMenu() ; Router.go 'profile'
    'click #login-buttons-settings': -> closeMenu() ; Router.go 'settings'
    'click input, click label, click button, click .dropdown-menu, click .alert': ( event ) -> event.stopPropagation()
    'click .login-close': -> __.closeDropdown() ; closeMenu() ; console.log "login-close"
    'click #login-name-link, click #login-sign-in-link': ( event ) -> 
        event.stopPropagation()
        __.set 'dropdownVisible', true
        Meteor.flush()
Template.loginButtons.toggleDropdown = -> toggleDropdown()
Template._loginButtonsLoggedOut.dropdown = -> Accounts.loginButtons.dropdown()        
Template._loginButtonsLoggedOut.services = -> Accounts.loginButtons.getLoginServices()
Template._loginButtonsLoggedOut.singleService = ->
    services = Accounts.loginButtons.getLoginServices()
    throw new Error "Shouldn't be rendering this template with more than one configured service" if services.length != 1
    services[0]
Template._loginButtonsLoggedOut.configurationLoaded = -> Accounts.loginServicesConfigured()

Template._loginButtonsLoggedIn.dropdown = -> Accounts.loginButtons.dropdown() # of cause
Template._loginButtonsLoggedIn.displayName = -> Accounts.loginButtons.displayName()

Template._loginButtonsMessages.errorMessage = -> __.get 'errorMessage'
Template._loginButtonsMessages.infoMessage = -> __.get 'infoMessage'

Template._loginButtonsLoggingInPadding.dropdown = -> Accounts.loginButtons.dropdown()

#
#
#

Template._loginButtonsLoggedOutSingleLoginButton.events
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
        loginWithService = Meteor[ "loginWith" + capitalize serviceName ]
        options = {}
        if Accounts.ui._options.requestPermissions[ serviceName ]
            options.requestPermissions = Accounts.ui._options.requestPermissions[ serviceName ]
        loginWithService options, callback
Template._loginButtonsLoggedOutSingleLoginButton.configured = -> !!Accounts.loginServiceConfiguration.findOne service: this.name
Template._loginButtonsLoggedOutSingleLoginButton.capitalizedName = -> if this.name == 'github' then 'GitHub' else capitalize this.name

#
#  
#

capitalize = ( str ) ->  
    str = if str == null then '' else String str
    str.charAt(0).toUpperCase() + str.slice 1

Template._loginButtonsLoggedInDropdown.events
    'click #login-buttons-change-password': ( event ) ->
        event.stopPropagation()
        __.resetMessages()
        __.set 'inChangePasswordFlow', true
        Meteor.flush()
#       toggleDropdown()
Template._loginButtonsLoggedInDropdown.displayName = -> Accounts.loginButtons.displayName()
Template._loginButtonsLoggedInDropdown.inChangePasswordFlow = -> __.get('inChangePasswordFlow')
Template._loginButtonsLoggedInDropdown.inMessageOnlyFlow = -> __.get('inMessageOnlyFlow')
Template._loginButtonsLoggedInDropdown.dropdownVisible = -> __.get('dropdownVisible')


Template._loginButtonsLoggedInDropdownActions.allowChangingPassword = ->  # what case?
    user = Meteor.user()
    user.username || ( user.emails && user.emails[0] && user.emails[0].address )
Template._loginButtonsLoggedInDropdownActions.additionalLoggedInDropdownActions = -> # It will be removed
    Template._loginButtonsAdditionalLoggedInDropdownActions != undefined

Template._loginButtonsLoggedOutDropdown.events
    'click #login-buttons-password': -> loginOrSignup()
    'keypress #forgot-password-email': ( event ) -> forgotPassword() if event.keyCode == 13
    'click #login-buttons-forgot-password': ( event ) -> event.stopPropagation() ; forgotPassword()
    'click #signup-link': ( event ) -> 
        event.stopPropagation()
        __.resetMessages()
        username = trimmedElementValueById 'login-username'
        email = trimmedElementValueById 'login-email'
        usernameOrEmail = trimmedElementValueById 'login-username-or-email'
        password = elementValueById 'login-password'
        __.set 'inSignupFlow', true
        __.set 'inForgotPasswordFlow', false
        Meteor.flush();
        if username != null
            document.getElementById('login-username').value = username
        else if email != null
            document.getElementById('login-email').value = email
        else if usernameOrEmail != null
            if usernameOrEmail.indexOf('@') == -1
                document.getElementById('login-username').value = usernameOrEmail
        else
            document.getElementById('login-email').value = usernameOrEmail
    'click #forgot-password-link': ( event ) ->
        event.stopPropagation()
        __.resetMessages()
        email = trimmedElementValueById 'login-email'
        usernameOrEmail = trimmedElementValueById 'login-username-or-email'
        __.set('inSignupFlow', false)
        __.set('inForgotPasswordFlow', true);
        Meteor.flush()
        if email != null
            document.getElementById('forgot-password-email').value = email
        else if usernameOrEmail != null
            if usernameOrEmail.indexOf('@') != -1
                document.getElementById('forgot-password-email').value = usernameOrEmail
    'click #back-to-login-link': ->
        __.resetMessages()
        username = trimmedElementValueById 'login-username'
        email = trimmedElementValueById('login-email') || trimmedElementValueById('forgot-password-email')
        __.set 'inSignupFlow', false
        __.set 'inForgotPasswordFlow', false
        Meteor.flush()
        document.getElementById('login-username').value = username if document.getElementById 'login-username'
        document.getElementById('login-email').value = email if document.getElementById 'login-email'
        document.getElementById('login-username-or-email').value = email || username if document.getElementById 'login-username-or-email'
    'keypress #login-username, keypress #login-email, keypress #login-username-or-email, keypress #login-password, keypress #login-password-again': ( event ) ->
        loginOrSignup() if event.keyCode == 13
Template._loginButtonsLoggedOutDropdown.additionalClasses = ->
    if !Accounts.password
        false
    else
        if __.get 'inSignupFlow'
            'login-form-create-account'
        else if __.get 'inForgotPasswordFlow'
            'login-form-forgot-password'
        else
            'login-form-sign-in'
Template._loginButtonsLoggedOutDropdown.dropdownVisible = -> __.get 'dropdownVisible'
Template._loginButtonsLoggedOutDropdown.hasPasswordService = -> Accounts.loginButtons.hasPasswordService()
Template._loginButtonsLoggedOutDropdown.forbidClientAccountCreation = -> Accounts._options.forbidClientAccountCreation # useless

Template._loginButtonsLoggedOutAllServices.services = -> Accounts.loginButtons.getLoginServices()
Template._loginButtonsLoggedOutAllServices.isPasswordService = -> this.name == 'password'
Template._loginButtonsLoggedOutAllServices.hasOtherServices = -> Accounts.loginButtons.getLoginServices().length > 1
Template._loginButtonsLoggedOutAllServices.hasPasswordService = -> Accounts.loginButtons.hasPasswordService()
Template._loginButtonsLoggedOutPasswordService.fields = ->
    loginFields = [
        fieldName: 'username-or-email'
        fieldLabel: 'Username or email'
        fieldIcon: 'user'
        visible: -> _.contains( 
            ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL"], 
            Accounts.ui._passwordSignupFields() )
    ,
        fieldName: 'username'
        fieldLabel: 'Username'
        fieldIcon: 'user'
        visible: -> Accounts.ui._passwordSignupFields() == "USERNAME_ONLY"
    ,
        fieldName: 'email'
        fieldLabel: 'Email'
        fieldIcon: 'envelope-o'
        inputType: 'email'
        visible: -> Accounts.ui._passwordSignupFields() == "EMAIL_ONLY"
    , 
        fieldName: 'password'
        fieldLabel: 'Password'
        fieldIcon: 'key'
        inputType: 'password'
        visible: -> true 
    ] 
    signupFields = [
        fieldName: 'username'
        fieldLabel: 'Username'
        fieldIcon: 'user'
        visible: -> _.contains(
            ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"],
            Accounts.ui._passwordSignupFields() )
    ,
        fieldName: 'email'
        fieldLabel: 'Email'
        fieldIcon: 'envelope-o'
        inputType: 'email'
        visible: -> _.contains(
            ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "EMAIL_ONLY"],
            Accounts.ui._passwordSignupFields() )
    ,
        fieldName: 'email'
        fieldLabel: 'Email (optional)'
        fieldIcon: 'envelope-o'
        inputType: 'email'
        visible: -> Accounts.ui._passwordSignupFields() == "USERNAME_AND_OPTIONAL_EMAIL"
    ,
        fieldName: 'password'
        fieldLabel: 'Password'
        fieldIcon: 'key'
        inputType: 'password'
        visible: -> true
    ,
        fieldName: 'password-again'
        fieldLabel: 'Password (again)'
        fieldIcon: 'key'
        inputType: 'password'
        visible: -> _.contains(
            ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"],
            Accounts.ui._passwordSignupFields() ) 
    ]
    signupFields = Accounts.ui._options.extraSignupFields.concat signupFields
    if __.get('inSignupFlow') then signupFields else loginFields

Template._loginButtonsLoggedOutPasswordService.inForgotPasswordFlow = -> __.get 'inForgotPasswordFlow'
Template._loginButtonsLoggedOutPasswordService.inLoginFlow = -> !__.get('inSignupFlow')  && !__.get 'inForgotPasswordFlow'
Template._loginButtonsLoggedOutPasswordService.inSignupFlow = -> __.get 'inSignupFlow'
Template._loginButtonsLoggedOutPasswordService.showForgotPasswordLink = -> _.contains(
    ["USERNAME_AND_EMAIL_CONFIRM", "USERNAME_AND_EMAIL", "USERNAME_AND_OPTIONAL_EMAIL", "EMAIL_ONLY"],
    Accounts.ui._passwordSignupFields() )
Template._loginButtonsLoggedOutPasswordService.showCreateAccountLink = -> !Accounts._options.forbidClientAccountCreation
Template._loginButtonsFormField.inputType = -> this.inputType || "text"

Template._loginButtonsChangePassword.events
    'keypress #login-old-password, keypress #login-password, keypress #login-password-again': ( event ) -> changePassword() if event.keyCode == 13
    'click #login-buttons-do-change-password': ( event ) -> event.stopPropagation() ; changePassword() ; console.log "change-password"
    'click #login-buttons-back-to-menu': ( event ) -> event.stopPropagation() ; closeMenu() ; console.log "back-to-menu"

Template._loginButtonsChangePassword.fields = -> [
    fieldName: 'old-password'
    fieldLabel: 'Current Password'
    fieldIcon: 'key'
    inputType: 'password'
    visible: -> true
,
    fieldName: 'password'
    fieldLabel: 'New Password'
    fieldIcon: 'asterisk'
    inputType: 'password'
    visible: -> true
,
    fieldName: 'password-again'
    fieldLabel: 'New Password (again)'
    inputType: 'password'
    visible: -> _.contains( ["USERNAME_AND_OPTIONAL_EMAIL", "USERNAME_ONLY"], Accounts.ui._passwordSignupFields() ) 
]
elementValueById = ( id ) ->
    element = document.getElementById( id )
    if element then element.value else null
trimmedElementValueById = ( id ) ->
    element = document.getElementById( id )
    if element then element.value.replace(/^\s*|\s*$/g, "") else null
loginOrSignup = -> if __.get 'inSignupFlow' then signup() else login()
login = -> 
    __.resetMessages()
    username = trimmedElementValueById 'login-username'
    email = trimmedElementValueById 'login-email'
    usernameOrEmail = trimmedElementValueById 'login-username-or-email'
    password = elementValueById 'login-password'
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
        if error then __.errorMessage( error.reason || "Unknown error" ) else __.closeDropdown()
toggleDropdown = -> $('#login-dropdown-list .dropdown-menu').dropdown('toggle') ; console.log "toggle Dropdown"

signup = -> 
    __.resetMessages()
    options = {}
    username = trimmedElementValueById 'login-username'
    if username != null
        if !Accounts.loginButtons.validateUsername username
            return
        else
            options.username = username
    email = trimmedElementValueById 'login-email'
    if email != null
        if !Accounts.loginButtons.validateEmail email
            return
        else
            options.email = email
    password = elementValueById 'login-password'
    if !Accounts.loginButtons.validatePassword password
        return
    else
        options.password = password
    return if !matchPasswordAgainIfPresent()
    options.profile = {}
    errorFn = ( errorMessage ) -> __.errorMessage(errorMessage)
    invalidExtraSignupFields = false
    _.each Accounts.ui._options.extraSignupFields, ( field, index ) ->
        value = elementValueById 'login-' + field.fieldName
        if typeof field.validate == 'function'
            if field.validate value, errorFn
                options.profile[ field.fieldName ] = elementValueById 'login-' + field.fieldName
            else
                invalidExtraSignupFields = true
        else
            options.profile[ field.fieldName ] = elementValueById 'login-' + field.fieldName
    return if invalidExtraSignupFields
    Accounts.createUser options, ( error ) ->
        if error then __.errorMessage error.reason || "Unknown error" else __.closeDropdown()
forgotPassword = ->
    __.resetMessages()
    email = trimmedElementValueById "forgot-password-email"
    if email.indexOf('@') != -1
        Accounts.forgotPassword email: email, ( error ) -> 
            if error then __.errorMessage error.reason || "Unknown error" else __.infoMessage "Email sent"  
    else
        __.infoMessage "Email sent"
changePassword = ->
    __.resetMessages()
    oldPassword = elementValueById 'login-old-password'
    password = elementValueById 'login-password'
    return if !Accounts.loginButtons.validatePassword password || !matchPasswordAgainIfPresent()
    Accounts.changePassword oldPassword, password, ( error ) ->
        if error
            __.errorMessage error.reason || "Unknown error" 
        else 
            __.infoMessage "Password changed"
            Meteor.setTimeout( -> 
                __.resetMessages() 
                __.closeDropdown()
                closeMenu()
            , 3000 )
matchPasswordAgainIfPresent = ->
    passwordAgain = elementValueById 'login-password-again'
    if passwordAgain != null
        password = elementValueById 'login-password'
        if password != passwordAgain
            __.errorMessage "Passwords don't match"
            return false
    true
__.set 'resetPasswordToken', Accounts._resetPasswordToken if Accounts._resetPasswordToken
__.set 'enrollAccountToken', Accounts._enrollAccountToken if Accounts._enrollAccountToken
Meteor.startup ->
    if Accounts._verifyEmailToken
        Accounts.verifyEmail Accounts._verifyEmailToken, ( error ) ->
            Accounts._enableAutoLogin()
            __.set 'justVerifiedEmail', true if !error

Template._resetPasswordDialog.rendered = ->
    $modal = $(this.find '#login-buttons-reset-password-modal' )
    $modal.modal()
Template._resetPasswordDialog.events
    'click #login-buttons-reset-password-button': -> resetPassword()
    'keypress #reset-password-new-password': ( event ) -> resetPassword() if event.keyCode == 13
    'click #login-buttons-cancel-reset-password': ->
        __.set 'resetPasswordToken', null
        Accounts._enableAutoLogin()
        $('#login-buttons-reset-password-modal').modal 'hide'
resetPassword = ->
    __.resetMessages()
    newPassword = document.getElementById('reset-password-new-password').value
    return if !Accounts.loginButtons.validatePassword newPassword
    Accounts.resetPassword __.get('resetPasswordToken'), newPassword, ( error ) ->
        if error
            __.errorMessage error.reason || "Unknown error"
        else
            __.set 'resetPasswordToken', null
            Accounts._enableAutoLogin()
            $('#login-buttons-reset-password-modal').modal "hide"
Template._resetPasswordDialog.inResetPasswordFlow = -> __.get('resetPasswordToken')
Template._enrollAccountDialog.events
    'click #login-buttons-enroll-account-button': -> enrollAccount()
    'keypress #enroll-account-password': ( event ) -> enrollAccount() if event.keyCode == 13
    'click #login-buttons-cancel-enroll-account-button': ->
        __.set 'enrollAccountToken', null
        Accounts._enableAutoLogin()
        $modal.modal "hide"
Template._enrollAccountDialog.rendered = ->
    $modal = $(this.find '#login-buttons-enroll-account-modal' )
    $modal.modal()

enrollAccount = ->
    __.resetMessages()
    password = document.getElementById('enroll-account-password').value
    return if !Accounts.loginButtons.validatePassword password
    Accounts.resetPassword __.get('enrollAccountToken'), password, ( error ) ->
        if error
            __.errorMessage error.reason || "Unknown error"
        else
            __.set 'enrollAccountToken', null
            Accounts._enableAutoLogin()
            $modal.modal "hide"
Template._enrollAccountDialog.inEnrollAccountFlow = -> __.get('enrollAccountToken')
Template._justVerifiedEmailDialog.events 'click #just-verified-dismiss-button': -> __.set('justVerifiedEmail', false)
Template._justVerifiedEmailDialog.visible = -> __.get('justVerifiedEmail')
Template._loginButtonsMessagesDialog.events 'click #messages-dialog-dismiss-button': -> __.resetMessages()
Template._loginButtonsMessagesDialog.visible = -> !Accounts.loginButtons.dropdown() && ( __.get('infoMessage') || __.get('errorMessage') )
Template._configureLoginServiceDialog.events
    'input, keyup input': ( event ) -> updateSaveDisabled() if event.target.id.indexOf 'configure-login-service-dialog' == 0
    'click .configure-login-service-dismiss-button': -> __.set 'configureLoginServiceDialogVisible', false
    'click #configure-login-service-dialog-save-configuration': ->
        if __.get('configureLoginServiceDialogVisible') && !__.get('configureLoginServiceDialogSaveDisabled')
            serviceName = __.get('configureLoginServiceDialogServiceName')
            configuration = service: serviceName
            _.each configurationFields(), ( field ) ->
                configuration[ field.property ] = document.getElementById(
                    'configure-login-service-dialog-' + field.property ).value.replace(/^\s*|\s*$/g, "")
            Meteor.call 'configureLoginService', configuration, ( error, result ) ->
                if error
                    Meteor._debug 'Error configuring login service ' + serviceName, error
                else
                    __.set 'configureLoginServiceDialogVisible', false
updateSaveDisabled = ->
    anyFieldEmpty = _.any(configurationFields(), ( field ) -> 
        document.getElementById( 'configure-login-service-dialog-' + field.property).value == '' )
    __.set 'configureLoginServiceDialogSaveDisabled', anyFieldEmpty
configureLoginServiceDialogTemplateForService = ->
    serviceName = __.get 'configureLoginServiceDialogServiceName'
    Template[ 'configureLoginServiceDialogFor' + capitalize serviceName ]
configurationFields = ->
    template = configureLoginServiceDialogTemplateForService()
    template.fields()
Template._configureLoginServiceDialog.configurationFields = -> configurationFields()
Template._configureLoginServiceDialog.visible = -> __.get 'configureLoginServiceDialogVisible'
Template._configureLoginServiceDialog.configurationSteps = -> configureLoginServiceDialogTemplateForService()()
Template._configureLoginServiceDialog.saveDisabled = -> __.get 'configureLoginServiceDialogSaveDisabled'
