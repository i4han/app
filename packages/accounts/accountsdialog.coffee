module.exports.accountsdialog =

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

        
