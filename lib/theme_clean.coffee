module.exports.theme_clean =
    br:
        jade_compile: """
            br(style='line-height:{{height}}')
            """

    __theme:
        styl_compile: """
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

.modal-backdrop
  opacity: 0.50

.fa
  width 10px
  height 10px

"""
