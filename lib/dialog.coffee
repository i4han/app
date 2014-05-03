module.exports.dialog =

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
            'click #login-buttons-reset-password-button': -> Accounts.ui.resetPassword()
            'keypress #reset-password-new-password': ( event ) -> Accounts.ui.resetPassword() if event.keyCode == 13
            'click #login-buttons-cancel-reset-password': ->
                Accounts.loginSession.set 'resetPasswordToken', null
                Accounts._enableAutoLogin()
                $('#login-buttons-reset-password-modal').modal 'hide'
        rendered: ->
            $modal = $(this.find '#login-buttons-reset-password-modal' )
            $modal.modal()
        inResetPasswordFlow: -> Accounts.loginSession.get('resetPasswordToken')
        
        

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
                Accounts.loginSession.set 'enrollAccountToken', null
                Accounts._enableAutoLogin()
                $modal.modal "hide"
        rendered: ->
            $modal = $(this.find '#login-buttons-enroll-account-modal' )
            $modal.modal()
        inEnrollAccountFlow: -> Accounts.loginSession.get('enrollAccountToken')

        

    _configureLoginServiceDialog:
        stylus: """
            #configure-login-service-dialog-modal
                position: fixed
                left: 50%
                margin-left: -300px
            """
        jade: """
            if visible
                .modal-dialog#configure-login-service-dialog-modal: .modal-content
                    .modal-header
                        h4.modal-title Configure Service
                    .modal-body: .accounts-dialog.accounts-centered-dialog#configure-login-service-dialog
                        +configurationSteps
                        p Now, copy over some details.
                        p: table
                            colgroup
                                col.configuration_labels(span="1")
                                col.configuration_inputs(span="1")
                            each configurationFields
                                tr
                                    td: label(for="configure-login-service-dialog-{{property}}") {{label}}
                                    td: input(id="configure-login-service-dialog-{{property}}" type="text")
                    .modal-footer(class="new-section")
                        .login-button.btn.btn-danger.configure-login-service-dismiss-button
                            | I'll do this later
                        .login-button.btn.btn-success.login-button-configure#configure-login-service-dialog-save-configuration(class="{{#if saveDisabled}}login-button-disabled{{/if}}")
                            | Save configuration
                .modal-backdrop.in
            """
        events:
            'input, keyup input': ( event ) -> 
                if event.target.id.indexOf 'configure-login-service-dialog' == 0
                    anyFieldEmpty = _.any(configurationFields(), ( field ) -> 
                        document.getElementById( 'configure-login-service-dialog-' + field.property).value == '' )
                    Accounts.loginSession.set 'configureLoginServiceDialogSaveDisabled', anyFieldEmpty            
            'click .configure-login-service-dismiss-button': -> Accounts.loginSession.set 'configureLoginServiceDialogVisible', false
            'click #configure-login-service-dialog-save-configuration': ->
                if Accounts.loginSession.get('configureLoginServiceDialogVisible') && !Accounts.loginSession.get('configureLoginServiceDialogSaveDisabled')
                    serviceName = Accounts.loginSession.get('configureLoginServiceDialogServiceName')
                    configuration = service: serviceName
                    _.each configurationFields(), ( field ) ->
                        configuration[ field.property ] = document.getElementById(
                            'configure-login-service-dialog-' + field.property ).value.replace(/^\s*|\s*$/g, "")
                    Meteor.call 'configureLoginService', configuration, ( error, result ) ->
                        if error
                            Meteor._debug 'Error configuring login service ' + serviceName, error
                        else
                            Accounts.loginSession.set 'configureLoginServiceDialogVisible', false
        helpers:
            configurationFields: -> configurationFields()
            visible: -> Accounts.loginSession.get 'configureLoginServiceDialogVisible'
            configurationSteps: -> templateForService()()
            saveDisabled: -> Accounts.loginSession.get 'configureLoginServiceDialogSaveDisabled'

            
            