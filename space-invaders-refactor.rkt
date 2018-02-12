;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname space-invaders-refactor) (read-case-sensitive #t) (teachpacks ()) (htdp-settings #(#t constructor repeating-decimal #f #t none #f () #f)))
(require 2htdp/image)
(require 2htdp/universe)


;; In response to previous comments:

;;> -4 When the spaceship is hit at the center, your game ends even it's the first time the spaceship got hit by a bullet.
;; Bug fixed.


;;> -8 most functions do not have tests
;; Essential tests have been added as necessary.


;;> -3 bad names for variables and functions like w, sb, ib
;; w was used originally by Theo during the lecture (I also beliveve it's a good
;; separation from the function game). In accordance of the previous homework,
;; I don't make any changes on the names.



;                              
;                              
;   ;;;;     ;;  ;;;;;;;   ;;  
;   ;   ;    ;;     ;      ;;  
;   ;    ;   ;;     ;      ;;  
;   ;    ;  ;  ;    ;     ;  ; 
;   ;    ;  ;  ;    ;     ;  ; 
;   ;    ;  ;  ;    ;     ;  ; 
;   ;    ;  ;;;;    ;     ;;;; 
;   ;   ;  ;    ;   ;    ;    ;
;   ;;;;   ;    ;   ;    ;    ;
;                              
;                              
;                              

;                                                                        
;                                                                        
;   ;;;;   ;;;;;  ;;;;;  ;;;;; ;;   ;  ;;;;; ;;;;;;; ;;;;;   ;;;; ;;   ; 
;   ;   ;  ;      ;        ;   ;;   ;    ;      ;      ;     ;  ; ;;   ; 
;   ;    ; ;      ;        ;   ;;;  ;    ;      ;      ;    ;    ;;;;  ; 
;   ;    ; ;      ;        ;   ; ;  ;    ;      ;      ;    ;    ;; ;  ; 
;   ;    ; ;;;;;  ;;;;;    ;   ; ;; ;    ;      ;      ;    ;    ;; ;; ; 
;   ;    ; ;      ;        ;   ;  ; ;    ;      ;      ;    ;    ;;  ; ; 
;   ;    ; ;      ;        ;   ;  ;;;    ;      ;      ;    ;    ;;  ;;; 
;   ;   ;  ;      ;        ;   ;   ;;    ;      ;      ;     ;  ; ;   ;; 
;   ;;;;   ;;;;;  ;      ;;;;; ;   ;;  ;;;;;    ;    ;;;;;   ;;;; ;   ;; 
;                                                                        
;                                                                        
;


;; A Direction is one of 
;; - 'up
;; - 'down 
;; - 'left
;; - 'right
;; INTERP: represents the the direction of the ship, the bullet of the ship
;;         the invader or the fire of the invader


;; A SpaceShip is (make-spaceship Direction Body)
;; INTERP: represents a spaceship with direction and position
(define-struct spaceship (dir body))


;; A SpaceshipBullet is (make-spaceship-bullet Posn PosInt PosInt)
;; INTERP: represents a spaceship bullet with its current location,
;;         the bullet's radius and the bullet's speed
(define-struct spaceship-bullet [location radius speed])

;; A ListOfSpaceshipBullets (LoSB) is one of
;; - empty
;; - (cons SpaceshipBullet LoSB)
;; INTERP: represents a list of spaceship bullets


;; An Invader is a Posn
;; INTERP: represents an invader with its position

;; A ListOfInvaders(LoI) is one of
;; - empty
;; - (cons Invader LoI)
;; INTERP: represents a list of invaders


;; A InvaderBullet is (make-invader-bullet Posn PosInt PosInt)
;; INTERP: represents an invader bullet with its current location,
;;         the bullet's radius and the bullet's speed
(define-struct invader-bullet [location radius speed])

;; A ListOfInvaderBullets (LoIB) is one of
;; - empty
;; - (cons InvaderBullet LoIB)
;; INTERP: represents a list of invader bullets

                         
;; A World is (make-world SpaceShip LoI LoSB LoIB Score Life Timer)
;; INTERP:  spaceship represents the spaceship  
;;          the list of invader represents the invders 
;;          the list of spaceship bullets represents the spaceship bullets
;;          the list of invader bullets represents the invader bullets
;;          the Score represents the score gained by the player
;;          the life represents the life remaining
;;          the timer represents the ticks that the invader moves downward


(define-struct world
  (spaceship invader spaceship-bullets invader-bullets score life timer))


;; text size
(define TEXT-SIZE 28)

;; scene width in pixels
(define WIDTH 400) 

;; scene height in pixels
(define HEIGHT 400) 

;; top center of the canvas
(define TOP-CENTER (make-posn (/ WIDTH 2) 15))

;; right bottom corner of the canvas
(define BOTTOM-RIGHT-CORNER (make-posn (- WIDTH  15)
                                       (- HEIGHT 15)))

;; segment side in pixels that decides the invader size
(define SEGMENT-SIDE 10)

;; background
(define BACKGROUND (empty-scene WIDTH HEIGHT))

;; spaceship width and height in pixels

(define SPACESHIP-SPEED 4)
(define SPACESHIP-WIDTH 30)
(define SPACESHIP-HEIGHT 10)

;; spaceship image
(define SPACESHIP-IMAGE (rectangle SPACESHIP-WIDTH
                                   SPACESHIP-HEIGHT
                                   'solid 'black))
;; spaceship bullet

(define SPACESHIP-BULLET-RADIUS 2)
(define SPACESHIP-BULLET-SPEED 8)
(define SPACESHIP-BULLET-IMAGE (circle SPACESHIP-BULLET-RADIUS 'solid 'black))

;; invader image
(define INVADER-IMAGE (square SEGMENT-SIDE 'solid 'red))

;; invader bullet
(define INVADER-BULLET-RADIUS 2)
(define INVADER-BULLET-SPEED 4)
(define INVADER-BULLET-IMAGE (circle INVADER-BULLET-RADIUS 'solid 'red))


;; boundary to draw the invaders
(define INVADER-LEFT (/ WIDTH 5))
(define INVADER-RIGHT (- WIDTH (/ WIDTH 5)))
(define INVADER-HORIZONTAL-SPACE (/ (- INVADER-RIGHT INVADER-LEFT) 8))

(define INVADER-UP (* SEGMENT-SIDE 4))
(define INVADER-DOWN (* SEGMENT-SIDE 8))
(define INVADER-VERTICAL-SPACE (/ (- INVADER-UP INVADER-DOWN) 3))

;; spaceship initial

(define SPACESHIP-INIT (make-spaceship 'right (make-posn (/ WIDTH 2)
                                                         (* (/ HEIGHT 2) 1.8))))

;; invader initial
(define INVADER-INIT (list (make-posn INVADER-LEFT INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 1 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 2 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 3 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 4 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 5 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 6 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 7 INVADER-HORIZONTAL-SPACE)) INVADER-UP)
                           (make-posn (+ INVADER-LEFT (* 8 INVADER-HORIZONTAL-SPACE)) INVADER-UP)

                           (make-posn INVADER-LEFT (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 1 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 2 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 3 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 4 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 5 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 6 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 7 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))
                           (make-posn (+ INVADER-LEFT (* 8 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP INVADER-VERTICAL-SPACE))

                           (make-posn INVADER-LEFT (- INVADER-UP ( * 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 1 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 2 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 3 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 4 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 5 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 6 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 7 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 8 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 2 INVADER-VERTICAL-SPACE)))

                           (make-posn INVADER-LEFT (- INVADER-UP ( * 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 1 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 2 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 3 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 4 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 5 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 6 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 7 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))
                           (make-posn (+ INVADER-LEFT (* 8 INVADER-HORIZONTAL-SPACE)) (- INVADER-UP (* 3 INVADER-VERTICAL-SPACE)))))

;; spaceship bullet initial 
(define SPACESHIP-BULLET-INIT empty)

;; invader bullet initial
(define INVADER-BULLET-INIT empty)

;; score initial
(define SCORE-INIT 0)

;; life initial
(define LIFE-INIT 3)

;; timer inital
(define TIMER-INIT 0)

;; timer frequency
(define FREQUENCY 10)



;; world initial
(define WORLD-INIT (make-world SPACESHIP-INIT
                               INVADER-INIT
                               SPACESHIP-BULLET-INIT
                               INVADER-BULLET-INIT
                               SCORE-INIT
                               LIFE-INIT
                               TIMER-INIT))


;                                                                 
;                                                                 
;   ;;;;;  ;    ;;;   ;    ;;; ;;;;;;; ;;;;;   ;;;; ;;   ;   ;;;; 
;   ;      ;    ;;;   ;   ;   ;   ;      ;     ;  ; ;;   ;  ;;   ;
;   ;      ;    ;;;;  ;  ;        ;      ;    ;    ;;;;  ;  ;     
;   ;      ;    ;; ;  ;  ;        ;      ;    ;    ;; ;  ;  ;;    
;   ;;;;;  ;    ;; ;; ;  ;        ;      ;    ;    ;; ;; ;   ;;;; 
;   ;      ;    ;;  ; ;  ;        ;      ;    ;    ;;  ; ;       ;
;   ;      ;    ;;  ;;;  ;        ;      ;    ;    ;;  ;;;       ;
;   ;      ;    ;;   ;;   ;   ;   ;      ;     ;  ; ;   ;;  ;    ;
;   ;       ;;;; ;   ;;    ;;;    ;    ;;;;;   ;;;; ;   ;;   ;;;; 
;                                                                 
;                                                                 
;                                                                 

;;;; Signature
;; draw-spaceship : SPACESHIP Image -> Image
;;;; Purpose
;; GIVEN: a spaceship and an image
;; RETURNS: a new image that draws the spaceship on the given image 
(define (draw-spaceship s img)
  (place-image SPACESHIP-IMAGE
               (posn-x (spaceship-body s))
               (posn-y (spaceship-body s)) img))

;;;; Tests
(check-expect (draw-spaceship
               (make-spaceship 'left (make-posn 100 100)) BACKGROUND)
              (place-image SPACESHIP-IMAGE 100 100 BACKGROUND))


;;;; Signature
;; draw-spaceship-bullets : ListOfSpaceshipBullets (LoSB) Image -> Image
;;;; Purpose
;; GIVEN: a LoSB and an image
;; RETURNS: a new image that draws the spaceship bullets on the given image 
(define (draw-spaceship-bullets losb img)
(foldl (lambda (x y) (place-image SPACESHIP-BULLET-IMAGE
                              (posn-x (spaceship-bullet-location x))
                              (posn-y (spaceship-bullet-location x)) y)) img losb))

;;;; Tests
(check-expect (draw-spaceship-bullets
               (list (make-spaceship-bullet (make-posn 100 100) 10 20))
               BACKGROUND)
              (place-image SPACESHIP-BULLET-IMAGE 100 100
                           BACKGROUND))

(check-expect (draw-spaceship-bullets
               (list (make-spaceship-bullet (make-posn 100 100) 10 20)
                     (make-spaceship-bullet (make-posn 250 250) 10 20)) BACKGROUND)
              (place-images(list SPACESHIP-BULLET-IMAGE
                                 SPACESHIP-BULLET-IMAGE)
                           (list (make-posn 100 100)
                                 (make-posn 250 250))

                           BACKGROUND))

;;;; Signature
;; draw-invaders : INVADERS Image -> Image
;;;; Purpose
;; GIVEN: a list of invaders and an image
;; RETURNS: a new image that draws the invaders on the given image
(define (draw-invaders los img)
(foldl (lambda (x y) (place-image INVADER-IMAGE
                                  (posn-x x)
                                  (posn-y x) y)) img los))

;;;; Tests
(check-expect (draw-invaders (list (make-posn 100 100)) BACKGROUND)
              (place-images(list INVADER-IMAGE)
                           (list (make-posn 100 100)) BACKGROUND))

(check-expect (draw-invaders (list (make-posn 100 100)
                                   (make-posn 250 250)) BACKGROUND)
              (place-images(list INVADER-IMAGE
                                 INVADER-IMAGE)
                           (list (make-posn 100 100)
                                 (make-posn 250 250)) BACKGROUND))

;;;; Signature
;; draw-invader-bullets : ListOfInvaderBullets (LoIB) Image -> Image
;;;; Purpose
;; GIVEN: a LoIB and an image
;; RETURNS: a new image that draws the invader bullets on the given image
(define (draw-invader-bullets loib img)
(foldl (lambda (x y) (place-image INVADER-BULLET-IMAGE
                              (posn-x (invader-bullet-location x))
                              (posn-y (invader-bullet-location x)) y)) img loib))
 
;;;; Tests
(check-expect (draw-invader-bullets
               (list (make-invader-bullet (make-posn 100 100) 10 20))
               BACKGROUND)
              (place-image INVADER-BULLET-IMAGE 100 100
                           BACKGROUND))

(check-expect (draw-invader-bullets
               (list (make-invader-bullet (make-posn 100 100) 10 20)
                     (make-invader-bullet (make-posn 250 250) 10 20)) BACKGROUND)
              (place-images(list INVADER-BULLET-IMAGE
                                 INVADER-BULLET-IMAGE)
                           (list (make-posn 100 100)
                                 (make-posn 250 250))
                           BACKGROUND))

;;;; Signature
;; draw-score : Score Image -> Image
;;;; Purpose
;; GIVEN: a Score and an image
;; RETURNS: a new image that draws the score on the given image
(define (draw-score s img)
  (place-image
   (text (number->string s) TEXT-SIZE "black")
   (posn-x TOP-CENTER)
   (posn-y TOP-CENTER)
   img))


;;;; Signature
;;;; draw-life: Life Image -> Image

;;;; Purpose
;; GIVEN: a life and an image
;; RETURNS: a new image with the life on the given image

(define (draw-life l img)
  (place-image
   (text (number->string l) TEXT-SIZE "red")
   (posn-x BOTTOM-RIGHT-CORNER)
   (posn-y BOTTOM-RIGHT-CORNER)
   img))


;;;; Signature
;; draw-world : World -> Image

;;;; Purpose
;; GIVEN: a world
;; RETURNS: an image representation of the given world
(define (draw-world w)
  (draw-life (world-life w)
  (draw-score (world-score w)
  (draw-invader-bullets (world-invader-bullets w)
  (draw-spaceship-bullets (world-spaceship-bullets w)
  (draw-spaceship (world-spaceship w)
  (draw-invaders (world-invader w) BACKGROUND)))))))

;;;; Signature 
;; body-move : Direction Body -> Body

;;;; Purpose
;; GIVEN: a direction and a body position of the spaceship
;; RETURNS: the updated body after moving one body unit in the
;;          appropriate direction.


;;;; Function Definition
(define (body-move dir body)
  (cond 
    [(symbol=? 'left dir)
     (make-posn (- (posn-x body) SPACESHIP-SPEED) (posn-y body))]
    [(symbol=? 'right dir) 
     (make-posn (+ (posn-x body) SPACESHIP-SPEED) (posn-y body))]))

;;;; Signature
;; spaceship-left? : SpaceShip => Boolean

;;;; Purpose
;; GIVEN: a spaceship
;; RETURNS: if the spaceship has reached the left boundary of the canvas

;;;; Function Definition
(define (spaceship-left? spaceship)
(<= (- (posn-x (spaceship-body spaceship)) (/ SPACESHIP-WIDTH 2)) 0))

;;;; Signature
;; spaceship-right? : SpaceShip => Boolean

;;;; Purpose
;; GIVEN: a spaceship
;; RETURNS: if the spaceship has reached the right boundary of the canvas

;;;; Function Definition
(define (spaceship-right? spaceship)
(>= (+ (posn-x (spaceship-body spaceship)) (/ SPACESHIP-WIDTH 2)) WIDTH))


;;;; Signature 
;; move-spaceship : Spaceship => Spaceship

;;;; Purpose: 
;; GIVEN: a spaceship
;; RETURNS: the spaceship after it moves by one body distance in the
;;          correct direction

;;;; Function Definiton
(define (move-spaceship s)
(cond
  [(and (spaceship-left? s)
        (symbol=? 'left (spaceship-dir s))) s]
  [(and (spaceship-right? s)
        (symbol=? 'right (spaceship-dir s))) s]
  [else (make-spaceship (spaceship-dir s)
              (body-move (spaceship-dir s) (spaceship-body s)))]))


;;;; Signature
;; move-spaceship-bullets: LoSB => LoSB

;;;; Purpose
;; GIVEN: a list of spaceship-bullets
;; RETURNS:  a new list of spaceship-bullets
;;           with updated position according to direction


;;;; Function Definition
(define (move-spaceship-bullets losb)
(local (
         ;;;; Signature
         ;; single-spaceship-bullet-move: SpaceShipBullet -> SpaceShipBullet

         ;;;; Purpose
         ;; GIVEN: a spaceship bullet
         ;; RETURNS: a spaceship bullet where the position has been updated
         

         ;;;; Function Definition
         (define (single-spaceship-bullet-move spaceship-bullet)
          (make-spaceship-bullet
             (make-posn
             (posn-x (spaceship-bullet-location spaceship-bullet))
             (- (posn-y (spaceship-bullet-location spaceship-bullet))
                (spaceship-bullet-speed spaceship-bullet)))
             (spaceship-bullet-radius spaceship-bullet)
             (spaceship-bullet-speed spaceship-bullet)))
        )
  (map single-spaceship-bullet-move losb)))


;;;; Tests
(check-expect (move-spaceship-bullets empty)
              empty)

(check-expect (move-spaceship-bullets (list
                (make-spaceship-bullet (make-posn 100 200) 30 20)
                (make-spaceship-bullet (make-posn 120 200) 30 20)
                (make-spaceship-bullet (make-posn 250 250) 30 30)
                (make-spaceship-bullet (make-posn 500 250) 20 30)))
 
               (list
                (make-spaceship-bullet (make-posn 100 180) 30 20)
                (make-spaceship-bullet (make-posn 120 180) 30 20)
                (make-spaceship-bullet (make-posn 250 220) 30 30)
                (make-spaceship-bullet (make-posn 500 220) 20 30)))


;;;; Signature
;; move-invader-bullets: LoIB => LoIB

;;;; Purpose
;; GIVEN: a list of invader-bullets
;; RETURNS:  a new list of invader-bullets
;;           with updated position according to direction

;;;; Function Definition
(define (move-invader-bullets loib)
(local (
        ;;;; Signature
        ;; single-invader-bullet-move: InvaderBullet -> InvaderBullet

        ;;;; Purpose
        ;; GIVEN: an invader bullet
        ;; RETURNS: an invader bullet where the position has been updated
         
        ;;;; Function Definition
        (define (single-invader-bullet-move invader-bullet)
         (make-invader-bullet
             (make-posn
             (posn-x (invader-bullet-location invader-bullet))
             (+ (posn-y (invader-bullet-location invader-bullet))
             (invader-bullet-speed invader-bullet)))
         (invader-bullet-radius invader-bullet)
         (invader-bullet-speed invader-bullet)))
        )


  (map single-invader-bullet-move loib)))

;;;; Tests

(check-expect (move-invader-bullets empty)
              empty)

(check-expect (move-invader-bullets (list
                (make-invader-bullet (make-posn 100 200) 30 20)
                (make-invader-bullet (make-posn 120 200) 30 20)
                (make-invader-bullet (make-posn 250 250) 30 30)
                (make-invader-bullet (make-posn 500 250) 20 30)))
 
              (list
                (make-invader-bullet (make-posn 100 220) 30 20)
                (make-invader-bullet (make-posn 120 220) 30 20)
                (make-invader-bullet (make-posn 250 280) 30 30)
                (make-invader-bullet (make-posn 500 280) 20 30)))



;;;; Signature
;; bullet-counter: A ListOfInvaderBullets (LoIB) or A ListOfSpaceBullets (LoSB)
;;                 => NonNegInteger

;;;; Purpose
;; GIVEN: a list of bullets (either spaceship or invader)
;; RETURNS: the number of bullets

;;;; Function Definition
(define (bullet-counter lob)
(length lob))

;;;; Signature
;; invader-counter: A ListOfInvaders (LoI) => NonNegInteger

;;;; Purpose
;; GIVEN: a list of invaders 
;; RETURNS: the number of invaders

;;;; Function Definition
(define (invader-counter loi)
(length loi))


;;;; Signature
;; move-invaders: A ListOfInvaders (LoI) => LoI

;;;; Puprose
;; GIVEN: a list of invaders
;; RETURNS: a updated list of invaders where the invaders have moved

;;;; Function Definition
(define (move-invaders loi)
  (local
    (
     ;;;; Signature
     ;; single-single-invader: Invader -> Invader

     ;;;; Purpose
     ;; GIVEN: an invader bullet
     ;; RETURNS: an invader bullet where the position has been updated
         
     ;;;; Function Definition
     (define (move-single-invader i)
       (make-posn  (posn-x i)
                   (+ (posn-y i) (/ SEGMENT-SIDE 2)))))
    (map move-single-invader loi)))

;;;; Tests
(check-expect (move-invaders empty)
              empty)

(check-expect (move-invaders (list
                              (make-posn 100 100)
                              (make-posn 200 200)
                              (make-posn 300 300)))
              (list
               (make-posn 100 105)
               (make-posn 200 205)
               (make-posn 300 305)))




;;;; Signature
;; move-invaders-with-timer: LoI Timer => LoI

;;;; Puprose
;; GIVEN: a list of invaders and a timer
;; RETURNS: a updated list of invaders where the invaders have moved

(define (move-invaders-with-timer loi timer)
  (cond
    [(= 0 (modulo timer FREQUENCY)) (move-invaders loi)]
    [else loi]))

;;;; Signature
;; lowest-invader-position: A ListOfInvaders(Loi) => NonNegativeReal

;;;; Puprose
;; GIVEN: a list of invaders
;; RETURNS: the lowest vertical positon of the invader

(define (lowest-invader-position loi)
(foldl (lambda (x y) (cond
                       [( > (posn-y x) y) (posn-y x)]
                       [else y])) 0 loi))

(check-expect (lowest-invader-position (list (make-posn 100 100))) 100)
(check-expect (lowest-invader-position (list (make-posn 100 100)
                                             (make-posn 200 200))) 200)
(check-expect (lowest-invader-position (list (make-posn 100 100)
                                             (make-posn 200 200)
                                             (make-posn 150 150))) 200)



;;;; Signature
;; invader-fire-random: A ListOfInvaders (LoI) => InvaderBullet

;;;; Purpose
;; GIVEN: a LoI
;; RETURNS: an InvaderBullet from the random invader to hit the ship

;;;; Function Definition
(define (invader-fire-random loi)
  (local (
          ;;;; Signature
          ;; invader-fire-index: A ListOfInvaders (LoI)  => NonNegInteger

          ;;;; Purpose
          ;; GIVEN: a list of invaders
          ;; RETURNS: the index of invader to fire

          ;;;; Function Definition
          (define (invader-fire-index loi)
            (random (invader-counter loi)))

          ;;;; Signature
          ;; invader-fire: A ListOfInvaders (LoI) and an index => InvaderBullet

          ;;;; Purpose
          ;; GIVEN: a LoI and the index of the invader to fire
          ;; RETURNS: an InvaderBullet from the indexed invader to hit the ship

          ;;;; Function Definition
          (define (invader-fire loi index)
           (cond
               [(= index 0) (make-invader-bullet
                (make-posn (posn-x (first loi))
                           (posn-y (first loi)))
                INVADER-BULLET-RADIUS
                INVADER-BULLET-SPEED)]
               [(> index 0) (invader-fire (rest loi) (- index 1))])))
    
    (invader-fire loi (invader-fire-index loi))))


;;;; Signature
;; update-loib: World => A List of Invader Bullets(LoIB)

;;;; Purpose
;; Given: a World
;; RETURNS: a updated list of invader bullets

;;;; Function Definition
(define (update-loib w)
(if (< (bullet-counter (world-invader-bullets w)) 10)
    (cons (invader-fire-random (world-invader w)) (world-invader-bullets w))
    (world-invader-bullets w)))


;;;; Signature
;; invader-hit? : An Invader and a SpaceshipBullet => Boolean

;;;; Purpose
;; GIVEN: an Invader and a SpaceshipBullet
;; RETURNS: a Boolean that decides if the invader is hit by a single bullet
          
;;;; Function Definition
(define (invader-hit? invader sb)
       (and
          (>= (+ (posn-x (spaceship-bullet-location sb)) (spaceship-bullet-radius sb))
          (- (posn-x invader) (/ SEGMENT-SIDE 2)))
    
          (<= (- (posn-x (spaceship-bullet-location sb)) (spaceship-bullet-radius sb))
          (+ (posn-x invader) (/ SEGMENT-SIDE 2)))

          (<= (- (posn-y (spaceship-bullet-location sb)) (spaceship-bullet-radius sb))
          (+ (posn-y invader) (/ SEGMENT-SIDE 2)))))


;;;; Signature
;; invader-hit-byany? : an Invader and a List of SpaceshipBullet => Boolean
;;;; Purpose
;; GIVEN: an Invader and a List of SpaceshipBullet
;; RETURNS: a Boolean that decides if the invader is hit by any of the bullet
;;;; Function Definition
(define (invader-hit-byany? invader losb)
   (ormap (lambda(x) (invader-hit? invader x)) losb))


;;;; Signature
;; any-invader-hit-byany?: a List of Invaders and a List of SpaceshipBullet
;;                         => Boolean

;;;; Purpose
;; GIVEN: a list of Invader and a List of SpaceshipBullet
;; RETURNS: a Boolean that decides if any invader is hit by any of the bullet
(define (any-invader-hit-byany? loi losb)
  (ormap (lambda(x) (invader-hit-byany? x losb)) loi))

;;;; Tests
(check-expect (any-invader-hit-byany? empty empty)
              #false)

(check-expect (any-invader-hit-byany?
               (list
                (make-posn 100 100))
               (list
                (make-spaceship-bullet (make-posn 100 100) 100 100)))
              #true)

(check-expect (any-invader-hit-byany?
               (list
                (make-posn -100 -100))
               (list
                (make-spaceship-bullet (make-posn 100 100) 100 100)))
              #false)


(check-expect (any-invader-hit-byany?
               (list
                (make-posn 100 100)
                (make-posn -100 -100))
               (list
                (make-spaceship-bullet (make-posn 100 100) 100 100)))
              #true)

;;;; Signature
;; remove-invaders: a List of Invaders and a List of SpaceshipBullet
;;                         => a List of Invaders
;; Purpose
;; GIVEN: a list of Invader and a List of SpaceshipBullet
;; RETURNS: a list of Invaders that are not hit by any spaceship bullet

;;;; Function Definition
(define (remove-invaders loi losb)
(filter (lambda (x) (not (invader-hit-byany? x losb))) loi))

;;;; Tests
(check-expect(remove-invaders
              (list (make-posn 100 100)
                    (make-posn 200 200))
              (list (make-spaceship-bullet (make-posn 100 100) 20 20)))
              (list (make-posn 200 200)))

(check-expect(remove-invaders
              (list (make-posn 100 100)
                    (make-posn 200 200))
              (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                    (make-spaceship-bullet (make-posn 200 200) 20 20)))
              empty)

(check-expect(remove-invaders
              (list (make-posn 100 100)
                    (make-posn 200 200))
              empty)
             (list (make-posn 100 100)
                    (make-posn 200 200)))


;;;; Signature
;; remove-hit-spaceship-bullets: a List of Invaders and a List of SpaceshipBullets
;;                         => a List of Spaceship Bullets


;;;; Function Definition
(define (remove-hit-spaceship-bullets loi losb)
  (local
    (
     ;;;; Signature
     ;; spaceship-bullet-hit-any? : a SpaceShip Bullet and a List of Invaders (LoI) => Boolean
     ;;;; Purpose
     ;; GIVEN:  a SpaceShip Bullet and a List of Invaders (LoI)
     ;; RETURNS: a Boolean that decides if that specific bullet hits any invader

     ;;;; Function Definition
     (define (spaceship-bullet-hit-any? loi sb)
       (ormap (lambda(x) (invader-hit? x sb)) loi)))

    (filter (lambda (x) (not (spaceship-bullet-hit-any? loi x))) losb)))

;;;; Test
(check-expect (remove-hit-spaceship-bullets
               (list (make-posn 100 100)
                     (make-posn 250 250))
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)))
               (list (make-spaceship-bullet (make-posn 200 200) 20 20)))

(check-expect (remove-hit-spaceship-bullets
                empty
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)))
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)))


;;;; Signature
;; remove-out-of-bound-spaceship-bullets: A List of SpaceShipBullet =>
;;                 A updated List of Bullets where the out-of-bound bullets
;;                 are removed

;;;; Purpose
;; GIVEN: a list of bullets
;; RETURNS: an updated list of bullets

;;;; Function Definition
(define (remove-out-of-bound-spaceship-bullets lob)
  (local
    (;;;; Signature
     ;; spaceship-bullet-out-of-bound?: A SpaceShipBullet => Boolean

     ;;;; Purpose
     ;; GIVEN: a spaceship bullet
     ;; RETURNS: a boolean variable that decides if the bullet is out of boundary

      ;;;; Function Definition
      (define (spaceship-bullet-out-of-bound? bullet)
      (if
        (or
         (> (posn-x (spaceship-bullet-location bullet)) WIDTH)
         (< (posn-x (spaceship-bullet-location bullet)) 0)
         (> (posn-y (spaceship-bullet-location bullet)) HEIGHT)
         (< (posn-y (spaceship-bullet-location bullet)) 0))
         #true
         #false)))
    (filter (lambda (x) (not (spaceship-bullet-out-of-bound? x))) lob)))

;;;; Tests

(check-expect (remove-out-of-bound-spaceship-bullets
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)
                     (make-spaceship-bullet (make-posn 200 (+ HEIGHT 200)) 20 20)))
              
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)))


(check-expect (remove-out-of-bound-spaceship-bullets
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)
                     (make-spaceship-bullet (make-posn 200 (+ HEIGHT 200)) 20 20)
                     (make-spaceship-bullet (make-posn (+ WIDTH 100) 100) 20 20)))
              
               (list (make-spaceship-bullet (make-posn 100 100) 20 20)
                     (make-spaceship-bullet (make-posn 200 200) 20 20)))


;;;; Signature
;; remove-out-of-bound-invader-bullets: A List of InvaderBullet =>
;;                 A updated List of Bullets where the out-of-bound bullets
;;                 are removed

;;;; Purpose
;; GIVEN: a list of bullets
;; RETURNS: an updated list of bullets

;;;; Function Definition
(define (remove-out-of-bound-invader-bullets lob)
  (local
    (;;;; Signature
     ;; spaceship-bullet-out-of-bound?: A SpaceShipBullet => Boolean

     ;;;; Purpose
     ;; GIVEN: a spaceship bullet
     ;; RETURNS: a boolean variable that decides if the bullet is out of boundary

      ;;;; Function Definition
      (define (invader-bullet-out-of-bound? bullet)
      (if
        (or
         (> (posn-x (invader-bullet-location bullet)) WIDTH)
         (< (posn-x (invader-bullet-location bullet)) 0)
         (> (posn-y (invader-bullet-location bullet)) HEIGHT)
         (< (posn-y (invader-bullet-location bullet)) 0))
         #true
         #false)))
    (filter (lambda (x) (not (invader-bullet-out-of-bound? x))) lob)))

;;;; Tests

(check-expect (remove-out-of-bound-invader-bullets
               (list (make-invader-bullet (make-posn 100 100) 20 20)
                     (make-invader-bullet (make-posn 200 200) 20 20)
                     (make-invader-bullet (make-posn 200 (+ HEIGHT 200)) 20 20)))
              
               (list (make-invader-bullet (make-posn 100 100) 20 20)
                     (make-invader-bullet (make-posn 200 200) 20 20)))


(check-expect (remove-out-of-bound-invader-bullets
               (list (make-invader-bullet (make-posn 100 100) 20 20)
                     (make-invader-bullet (make-posn 200 200) 20 20)
                     (make-invader-bullet (make-posn 200 (+ HEIGHT 200)) 20 20)
                     (make-invader-bullet (make-posn (+ WIDTH 100) 100) 20 20)))
              
               (list (make-invader-bullet (make-posn 100 100) 20 20)
                     (make-invader-bullet (make-posn 200 200) 20 20)))


;;;; Signature
;; ship-hit-byany? : A SpaceShip and a List of Invader Bullets(loib) => Boolean

;;;; Purpose
;; GIVEN: a list of Invader Bullets and a SpaceshipBullet
;; RETURNS: a boolean that decides if the spaceship is hit by the bullet

;;;; Function Definition
(define (ship-hit-byany? spaceship loib)
(local
  (;;;; Signature
   ;; ship-single-bullet-hit? : A SpaceShip and an InvaderBullet => Boolean

   ;;;; Purpose
   ;; GIVEN: an Invader and a SpaceshipBullet
   ;; RETURNS: a boolean that decides if the spaceship is hit by the bullet

    ;;;; Function Definition
    (define (ship-single-bullet-hit? spaceship ib)
    (and
     (<= (- (posn-x (invader-bullet-location ib)) INVADER-BULLET-RADIUS)
         (+ (posn-x (spaceship-body spaceship)) (/ SPACESHIP-WIDTH 3))) 
 
     (>= (+ (posn-x (invader-bullet-location ib)) INVADER-BULLET-RADIUS)
         (- (posn-x (spaceship-body spaceship)) (/ SPACESHIP-WIDTH 3))) 

     (>= (+ (posn-y (invader-bullet-location ib)) INVADER-BULLET-RADIUS)
         (- (posn-y (spaceship-body spaceship)) (/ SPACESHIP-HEIGHT 20)))

     (<= (- (posn-y (invader-bullet-location ib)) INVADER-BULLET-RADIUS)
         (+ (posn-y (spaceship-body spaceship)) (/ SPACESHIP-HEIGHT 20))))))
    (ormap (lambda (x) (ship-single-bullet-hit? spaceship x)) loib)))

;;;; Tests
(check-expect (ship-hit-byany?
               (make-spaceship 'left (make-posn 250 250))
               (list (make-invader-bullet (make-posn 250 250) 10 10)
                     (make-invader-bullet (make-posn 100 100) 10 10))) #true)

(check-expect (ship-hit-byany?
               (make-spaceship 'left (make-posn 250 250))
               (list (make-invader-bullet (make-posn 150 150) 10 10)
                     (make-invader-bullet (make-posn 100 100) 10 10))) #false)



;;;; Signature
;; ship-hit? : A World => Boolean

;;;; Purpose
;; GIVEN: a list World
;; RETURNS: if the ship is hit by any invader bullets

;;;; Function Definition
(define (ship-hit? w)
 (ship-hit-byany? (world-spaceship w) (world-invader-bullets w)))

;;;; Signature
;; spaceship-fire : A World => A updated List of LoSB
                                                     
;;;; Purpose
;; GIVEN: a list of Spaceship Bullets
;; RETURNS: a new spaceship bullets added if less than 3 spaceship bullets 

;;;; Function Definition
(define (spaceship-fire w)
(if (< (bullet-counter (world-spaceship-bullets w)) 3)
    (cons (make-spaceship-bullet
         (spaceship-body (world-spaceship w))
         SPACESHIP-BULLET-RADIUS
         SPACESHIP-BULLET-SPEED) (world-spaceship-bullets w))
(world-spaceship-bullets w)))


;;;; Signature
;; update-score: World -> Score
;;;; Purpose
;; GIVEN: the current world
;; RETURNS: a new score

(define (update-score w)
  (* 3 (- 36 (invader-counter (world-invader w)))))

;;;; Signature
;; update-timer: World -> Timer
;;;; Purpose
;; GIVEN: the current world
;; RETURNS: a new timer

(define (update-timer w)
  ( modulo (+ 1 (world-timer w)) FREQUENCY))


;;;; Signature 
;; key-handler : World Key-Event -> World
;;;; Purpose
;; GIVEN: the current world and a key event
;; RETURNS: a new world with direction updated according to the key event.
(define (key-handler w ke)
  (cond 
    [(or (key=? ke "left")
         (key=? ke "right"))
     (make-world (make-spaceship (string->symbol ke)
                             (spaceship-body (world-spaceship w)))
                 (world-invader w)
                 (world-spaceship-bullets w)
                 (world-invader-bullets w)
                 (world-score w)
                 (world-life w)
                 (world-timer w))]
    [(key=? ke " ")
     (make-world (world-spaceship w)
                 (world-invader w)
                 (spaceship-fire w)
                 (world-invader-bullets w)
                 (world-score w)
                 (world-life w)
                 (world-timer w))]
    [else w]))

;;;; Signature 
;; end-game? : World -> Boolean
;;;; Signature 
;; GIVEN: the current world
;; RETURNS: true if one of the condition that end the game has been met,
;;          false otherwise
(define (end-game? w)
  (or (= 0 (world-life w))
      (= 0 (invader-counter (world-invader w)))
      (= (posn-y (spaceship-body (world-spaceship w)))
         (lowest-invader-position (world-invader w)))))


;;;; Signature 
;; ship-resurrect : World -> World
;;;;; Purpose
;; GIVEN: the current world
;; RETURNS: a new world where 
;; 1. The ship resurrect at the beginning position
;; 2. The life of ship has decreased by one

;;;; Function Definition
(define (ship-resurrect w)
  (make-world  SPACESHIP-INIT
               (world-invader w)
               (world-spaceship-bullets w)
               (move-invader-bullets (world-invader-bullets w))
               (world-score w)
               ( - (world-life w) 1)
               (update-timer w)))




;;;; Signature 
;; remove-invaders-from-world : World -> World

;;;;; Purpose
;; GIVEN: the current world
;; RETURNS: a new world where 
;; 1. The ship moves in the given direction
;; 2. The hit invader has been removed
;; 3. The hit spaceship bullets have been removed
;; 4. The invader bullets and spaceship keep moving

;;;; Function Definition
(define (remove-invaders-from-world w)
(make-world (move-spaceship(world-spaceship w))
            (move-invaders-with-timer
             (remove-invaders (world-invader w)
                              (world-spaceship-bullets w))
            (world-timer w))      
            (move-spaceship-bullets
            (remove-hit-spaceship-bullets (world-invader w)
                                          (world-spaceship-bullets w)))
            (move-invader-bullets (world-invader-bullets w))
            (update-score w)
            (world-life w)
            (update-timer w)))


;;;; Signature 
;; update-world : World -> World

;;;;; Purpose
;; GIVEN: the current world
;; RETURNS: a new world where 
;; 1. The ship moves in the given direction
;; 2. The invaders are kept as original
;; 3. A random invader fires if there is less than 10 invader bullets
;; 4. The out-of-bounds bullets have been removed
;; 5. The invader and spaceship keeps moving

;;;; Function Definition
(define (update-world w)
(make-world (move-spaceship (world-spaceship w))
            (move-invaders-with-timer (world-invader w) (world-timer w))
            (move-spaceship-bullets 
            (remove-out-of-bound-spaceship-bullets (world-spaceship-bullets w)))
            (move-invader-bullets(remove-out-of-bound-invader-bullets (update-loib w)))
            (update-score w)
            (world-life w)
            (update-timer w)))

;;;; Signature 
;; world-step: World -> World
;;;; Purpose
;; GIVEN: the current world
;; RETURNS: the next world after one clock tick  
(define (world-step w)  
  (cond
    [(ship-hit? w)(ship-resurrect w)]
    [(any-invader-hit-byany? (world-invader w) (world-spaceship-bullets w))
     (remove-invaders-from-world w)]
    [else (update-world w)]))


(big-bang WORLD-INIT
          (to-draw draw-world)
          (on-tick world-step 0.08)
          (on-key key-handler)
          (stop-when end-game?))









              




