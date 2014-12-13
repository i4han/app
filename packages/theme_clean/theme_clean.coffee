module.exports.theme_clean =

    __theme:
        stylus: """
body
    font-family 'PT Sans', sans-serif
    font-weight 200

.tooltip
    width 300px

.tooltip-inner
    width 100%
    text-align left
    color white
    background-color green

    
.btn
  font-family 'PT Sans'
  width 150px //166
  border 0

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
  
li.selected
  background-color #a4c5ff


.container-fluid#main-body
  padding-top 70px
  
.half-line
  line-height 0
.single-line
  line-height 18px  
.double-line
  line-height 36px
.triple-line
  line-height 54px


.modal-backdrop
  opacity: 0.50

#login-buttons-reset-password-modal, #login-buttons-enroll-account-modal
  .modal-content
    margin-top: 30%;

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
.or
  text-align: center

#login-buttons
  display: none;

#login-dropdown-list a
  cursor: pointer;

.dropdown-menu
  top 50px
  margin 0px
  font-weight 200
  text-align left
  line-height 20px
  border-radius 1px

  &#logged-in-dropdown
    right 0
    left auto
    width 186px
    padding-left 0px
    padding-right 0px
    padding-top 5px
    padding-bottom 5px

.dropdown-menu > li > a
  font-weight 200

.dropdown-menu-icon
  margin-right 12px

.dropdown-menu-link
  line-height 25px



// login dropdown

li#login-dropdown-list
  float right
  width 100px
  line-height 50px
  display table-cell
  text-align right
  vertical-align middle

  .dropdown
    height 50px

#login-dropdown-list input
#login-dropdown-list input:first-of-type
#login-dropdown-list input:last-of-type
  margin-bottom 0px
  border-top-left-radius 0px
  border-top-right-radius 5px
  border-bottom-left-radius 0px
  border-bottom-right-radius 5px


.fa
  width 10px
  height 10px

"""
