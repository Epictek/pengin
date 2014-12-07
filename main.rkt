#lang racket/gui

#| ############### GUI ################## |#
; create a new top-level window
; Make a frame by instantiating the frame% class

(define frame (new frame%
                   [label "pengin"]
                   [width 800]
                   [height 400]
                   [x 0]
                   [y 0]
                   ))


(define tab-panel(new tab-panel%
                      [choices (list "Currently Watching" "Plan to Watch" "Completed" "On Hold" "Dropped" )]
                      [parent frame]
                      [min-height 300]
                      [callback (λ(b e)
                                  (getUserLibary)
                                  )])
)

(define list-box (new list-box%
                      [label #f]
                      [parent tab-panel]
                      [style (list 'single 'vertical-label 'column-headers 'reorderable-headers)]
                      [choices (list "Loading")]
                      [columns (list "Title" "Progress" "Rating" "Type")]
                      )
)




(new button% [parent frame]
             [label "Settings"]
             [callback (λ(b e)
                         
                         )]
             )


;This can probably be set dynamically, would be nice to be able to use % but not sure that is possible 
(send list-box set-column-width 0 500 200 1000)
(send list-box set-column-width 1 100 10 1000)
(send list-box set-column-width 2 100 10 1000)
(send list-box set-column-width 3 50 10 1000)



(send frame show #t)


;#########



(require wffi/client)
(define (add-common-parameters d)
  (dict-set* d 'X-Mashape-Key "X-Mashape-Key: "))
(wffi-define-all "hummingbird-md/hummingbird.md" add-common-parameters check-response/json)
(provide (all-defined-out))


(define libary (make-hash))
(define listAnimeID '())
(define listTitles '())
(define listEpisodes '())
(define listRating '())
(define listType '())

(define getUserLibary (lambda ()
                  (send list-box clear)
                  (define type (send tab-panel get-selection))
                  (define status "currently-watching")
                  (if (= type 0) (set! status "currently-watching") 
                  (if (= type 1) (set! status "plan-to-watch")    
                  (if (= type 2) (set! status "completed")
                  (if (= type 3) (set! status "on-hold")
                  (if (= type 4) (set! status "dropped")(#f))))))
                        
                  (set! listTitles '())
                  (set! listEpisodes '())
                  (set! listRating '())
                  (set! listType '())
                  (define json-hash(library 'username "epictek" 'status status))
                  (for ((h (in-list json-hash))) 
                    (for (([key value] h))
                      (hash-set! libary key value)
                      )
                    (define anime-hash (hash-ref libary 'anime))
                    (set! listTitles (append listTitles (list (hash-ref anime-hash 'title))))
                    (define episodes_watched(number->string(hash-ref libary 'episodes_watched)))
                    (define episode_count(number->string( hash-ref anime-hash 'episode_count)))
                    (set! listEpisodes (append listEpisodes (list (format "~a/~a" episodes_watched episode_count))))   
                    (define rating-hash (hash-ref libary 'rating))
                    (define rating(hash-ref rating-hash 'value))
                    (if(string? rating)(set! rating rating)(set! rating "---"))
                    (set! listRating (append listRating (list rating)))
                    (set! listType (append listType (list (hash-ref anime-hash 'show_type))))
                    )
                        (send list-box set listTitles listEpisodes listRating listType)
                  )
  
)


(getUserLibary)






