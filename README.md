# ZenPaste

A very simple pastebin server  

## Dependencies  
`cpan install Mojolicious::Lite`

## /new  
 Takes post data and stores it in file: data/$id using Storable.
Returns link to file
## /:id
Retrieves paste by id
