#lang racket

(define (check-range num min max)
  (and (or (< num max) (= num max)) (or (> num min) (= num min))))

(define (check-temps1 temps)
  (if (empty? temps)
      true
      (and (check-range(first temps) 5 95) (check-temps1(rest temps)))))

(define (check-temps temps low high)
  (if (empty? temps)
      true
      (and (check-range(first temps) low high) (check-temps(rest temps) low high))))

(define (list-to-str list str)
  (if (empty? list) 
      str
      (list-to-str (rest list) (string-append (number->string (first list)) str))))

(define (reverse-list list reversed-list)
  (if (empty? list)
      reversed-list
      (reverse-list (rest list)(cons (first list) reversed-list))))

(define (convert digits)
  (string->number (list-to-str digits "")))

(define (get-duple remaining-list duple-list)
  (if (empty? remaining-list)
     duple-list
     (get-duple (rest remaining-list) (cons (list (first remaining-list) (first remaining-list)) duple-list))))

(define (duple lst)
  (reverse-list (get-duple lst '()) '()))

(define (sum lst)
  (if (empty? lst)
      0
      (+ (first lst) (sum (rest lst)))))

(define (count lst)
  (if (empty? lst)
      0
      (+ 1 (count (rest lst)))))       
(define (average lst)
  (/ (sum lst) (count lst)))

(define (fToC num)
  (/ (* 5 (- num 32)) 9))

(define (tempsConvert temps newList)
    (if (empty? temps)
        newList
        (tempsConvert (rest temps) (cons (fToC(first temps)) newList))))

(define (convertFC temps)
  (reverse-list (tempsConvert temps '()) '()))

(define (keepIfValid newNum lst)
  (if (empty? lst)
      (cons newNum lst)
      (if (or (> (first lst) newNum) (= (first lst) newNum))
          (cons newNum lst)
          lst)))
 
(define (getRidOfLarge lst newLst)
  (if (empty? lst)
      newLst
      (getRidOfLarge (rest lst) (keepIfValid (first lst) newLst))))
  

(define (eliminate-larger lst)
  (getRidOfLarge (reverse-list lst '()) '()))
      
 
(check-temps1 (list 95 6 7))
(check-temps (list 20 100) 20 100)
(check-range 20 20 100)
(reverse-list (list 6 3 4 7) '())
(convert (list 2 3))
(duple '(100 299 300))
(define empty '())
(cons 41 (cons 42 empty))
(average (list 1 2 3 4))
(convertFC (list 68 32 51 212))
(eliminate-larger (list 5 4 3 2 1))
