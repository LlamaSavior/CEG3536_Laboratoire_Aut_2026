/* ---------------------------------------------------------------------------
 * fsm.s — machine à états du panneau de commande (CEG 3536, laboratoire 1)
 *
 * Routines exportées : fsm_init (fournie), fsm_step (À COMPLÉTER)
 * Variables (.bss)   : etat, touch_enabled, compteur_transitions,
 *                      clignote_compteur, clignote_phase, touch_signal_compteur
 *
 * États (section 3) : ETAT_ARRET (rouge fixe), ETAT_MARCHE_AVANT (verte),
 *                     ETAT_MARCHE_ARRIERE (bleue), ETAT_ARRET_URGENCE (rouge 2 Hz)
 * Un seul point de mise à jour des DEL : fsm_maj_del (critère B3).
 * ------------------------------------------------------------------------- */
#include "registres.inc"
#include "registres_lab2.inc"

    .syntax unified
    .cpu    cortex-m33
    .thumb

    .bss
    .align  2

    .global etat
etat:                   .space  4   /* état courant (ETAT_x)                     */

    .global compteur_transitions
compteur_transitions:   .space  4   /* nombre de transitions validées (T3, watch) */

	.global clignote_compteur
clignote_compteur:      .space  4   /* pas de scrutation écoulés dans la demi-période */

	.global clignote_phase
clignote_phase:         .space  4   /* 0 rouge éteinte, 1 rouge allumée (E5)     */

.global consigne_pct
consigne_pct:           .space 4

.global pwm_pct
pwm_pct:                .space 4

.global rampe_compteur
rampe_compteur:         .space 4

.global fenetre_compteur
fenetre_compteur:       .space 4

prochain_sens:          .space 4
/* ---- Table état -> DEL (un octet par état) ------------------------------ */
    .section .rodata

    etat_vers_dir:
	    .word MOTOR_ARRET
	    .word MOTOR_AVANT
	    .word MOTOR_ARRIERE
	    .word MOTOR_ARRET

	etat_vers_bips:
	    .word 1
	    .word 1
	    .word 2
	    .word 0

etat_vers_del:
    .byte   LED_ROUGE       /* ETAT_ARRET          */
    .byte   LED_VERTE       /* ETAT_MARCHE_AVANT   */
    .byte   LED_BLEUE       /* ETAT_MARCHE_ARRIERE */
    .byte   LED_ROUGE       /* ETAT_ARRET_URGENCE (clignotante, voir fsm_maj_del) */

    .text
    .align  2

/* void fsm_init(void)
 * État initial ARRÊT, variables à zéro, DEL rouge seule (E1).
 * Appelle fsm_maj_del : LR sauvegardé ; push {r4, lr} garde l'alignement 8. */
    .global fsm_init
    .type   fsm_init, %function
fsm_init:
    push    {r4, lr}
    movs    r1, #0
    ldr     r0, =etat
    movs    r2, #ETAT_ARRET
    str     r2, [r0]

    ldr     r0, =compteur_transitions
    str     r1, [r0]

    ldr r0, =consigne_pct
    movs r1, #CONSIGNE_INITIALE
    str r1, [r0]

    ldr r0, =pwm_pct
    movs r1, #0
    str r1, [r0]

    ldr r0, =rampe_compteur
    movs r1, #0
    str r1, [r0]

    ldr r0, =fenetre_compteur
    movs r1, #0
    str r1, [r0]

    ldr r0, =buzzer_continu
    movs r1, #0
    str r1, [r0]

    ldr     r0, =clignote_compteur
    movs	r1, #0
    str     r1, [r0]

    ldr r0, =clignote_compteur
    movs r1, #0
    str r1, [r0]

    ldr r0, =clignote_phase
    movs r1, #1
    str r1, [r0]

    ldr r0, =prochain_sens
    movs r1, #0
    str r1, [r0]

    bl      fsm_maj_sorties
    pop     {r4, pc}
    .size   fsm_init, .-fsm_init

.global fsm_entree_etat
.thumb_func
fsm_entree_etat:
    push {r4, lr}

    /*r0=nouvel état */
    ldr r1, =etat
    str r0, [r1]

    /* compteur transitions*/
    ldr r1, =compteur_transitions
    ldr r2, [r1]
    adds r2, r2, #1
    str r2, [r1]

    /*reset rampe*/
    ldr r1, =pwm_pct
    movs r2, #0
    str r2, [r1]
    ldr r1, =rampe_compteur
    movs r2, #0
    str r2, [r1]

    /*direction*/
    ldr r1, =etat_vers_dir
    lsls r2, r0, #2
    adds r1, r1, r2
    ldr r0, [r1]
    bl motor_set_dir

    /*bips*/
    ldr r1, =etat_vers_bips
    lsls r2, r0, #2
    adds r1, r1, r2
    ldr r0, [r1]
    bl buzzer_bip

    pop {r4, pc}
/* void fsm_step(void)
 * Un pas de la machine à états, appelé toutes les PERIODE_SCRUTATION_MS.
 * Lit les événements validés (button_pressed) et le drapeau estop_flag,
 * applique les transitions E2 à E7, puis met à jour les DEL (fsm_maj_del).
 *
 * À COMPLÉTER — ordre recommandé :
 *   A. E4/E5 : si estop_flag == 1 : estop_flag = 0 ; etat = ETAT_ARRET_URGENCE ;
 *      clignote_compteur = 0 ; clignote_phase = 1.
 *   B. si etat == ETAT_ARRET_URGENCE :
 *        - E5 : les appuis sur User sont ignorés (appeler quand même
 *          button_pressed(BTN_USER) pour entretenir l'anti-rebond) ;
 *        - E6 : si button_pressed(BTN_TOUCH) == 1 ET button_raw(BTN_ESTOP) == 0
 *          (E-Stop relâché) : etat = ETAT_ARRET (acquittement). Sinon rester.
 *      sinon :
 *        - E2 : si button_pressed(BTN_USER) == 1 :
 *              ARRET -> MARCHE_AVANT, MARCHE_AVANT -> ARRET (puis ARRET -> MARCHE_ARRIERE
 *              au prochain appui, MARCHE_ARRIERE -> ARRET). Une variable "prochain sens"
 *              en .bss permet d'alterner avant/arrière à partir d'ARRÊT.
 *              compteur_transitions++ à chaque transition.
 *        - E7 : si button_pressed(BTN_TOUCH) == 1 : touch_enabled ^= 1 ;
 *              touch_signal_compteur = TOUCH_SIGNAL_MS / PERIODE_SCRUTATION_MS.
 *   C. bl fsm_maj_del.
 * Invariants (E9) : jamais deux DEL allumées (garanti par led_set) ; jamais de
 * sortie d'ARRÊT_URGENCE sans acquittement.
 * AAPCS : appelle d'autres routines -> push {r4, lr}.                         */
    .global fsm_step
    .type   fsm_step, %function
.thumb_func
fsm_step:
    push    {r4, lr}

    /* ----- À COMPLÉTER : étapes A et B ----- */

    /*etape A*/
    ldr     r0, =estop_flag
    ldr     r1, [r0]
    cmp     r1, #1
    beq     fsm_estop

    /*état courant*/
    ldr     r0, =etat
    ldr     r4, [r0]

    /* etape B => ARRET_URGENCE*/
    cmp     r4, #ETAT_ARRET_URGENCE
    beq     fsm_urgence

    /*bouton user */
    movs    r0, #BTN_USER
    bl      button_pressed
    cmp     r0, #1
    beq     fsm_user

    /*bouton touch*/
    movs    r0, #BTN_TOUCH
    bl      button_pressed
    cmp     r0, #1
    beq     fsm_touch

    bl      fsm_fenetre
    bl      fsm_maj_sorties
    pop     {r4, pc}
    .size fsm_step, .-fsm_step

.thumb_func
fsm_estop:
    /*estop_flag = 0*/
    ldr     r0, =estop_flag
    movs    r1, #0
    str     r1, [r0]

    /*etat = ARRET_URGENCE*/
    movs    r0, #ETAT_ARRET_URGENCE
    bl fsm_entree_etat

    pop {r4, pc}

.thumb_func
fsm_urgence:
    movs    r0, #BTN_USER
    bl      button_pressed

    /*bouton touch*/
    movs    r0, #BTN_TOUCH
    bl      button_pressed
    cmp     r0, #1
    bne     fsm_urgence_fin

    /*bouton estop*/
    movs    r0, #BTN_ESTOP
    bl      button_raw
    cmp     r0, #0
    bne     fsm_urgence_fin

    movs r0, #ETAT_ARRET
    bl fsm_entree_etat

fsm_urgence_fin:
    bl fsm_maj_sorties
    pop {r4, pc}

.thumb_func
fsm_user:
    ldr     r0, =etat
    ldr     r1, [r0]

    cmp     r1, #ETAT_ARRET
    beq     fsm_user_arret

    /* avant a arret*/
    cmp     r1, #ETAT_MARCHE_AVANT
    beq     fsm_user_vers_arret

    /* arriere a arret*/
    cmp     r1, #ETAT_MARCHE_ARRIERE
    beq     fsm_user_vers_arret

	pop     {r4, pc}

.thumb_func
fsm_user_arret:
    ldr     r2, =prochain_sens
    ldr     r3, [r2]
    cmp     r3, #0
    beq     fsm_arret_avant

    movs    r0, #ETAT_MARCHE_ARRIERE
    bl      fsm_entree_etat

    movs    r3, #0
    str     r3, [r2]
    pop     {r4, pc}

.thumb_func
fsm_arret_avant:
    movs    r0, #ETAT_MARCHE_AVANT
    bl      fsm_entree_etat

    movs    r3, #1
    str     r3, [r2]
    pop     {r4, pc}

.thumb_func
fsm_user_vers_arret:
    movs    r0, #ETAT_ARRET
    bl      fsm_entree_etat
    pop     {r4, pc}

.thumb_func
fsm_touch: /*touchpad au lab4*/
ldr r0, =consigne_pct
    ldr r1, [r0]
    adds r1, r1, #CONSIGNE_PAS
    cmp r1, #CONSIGNE_MAX
    ble fsm_touch_ok
    movs r1, #CONSIGNE_MIN
fsm_touch_ok:
    str r1, [r0]

    movs r0, #1
    bl buzzer_bip

    bl fsm_maj_sorties
    pop {r4, pc}

 .thumb_func
 fsm_fenetre:
    ldr r0, =fenetre_compteur
    ldr r1, [r0]
    adds r1, r1, #1
    str r1, [r0]

    cmp r1, #FENETRE_VITESSE_MS
    blo fsm_fenetre_fin

    movs r1, #0
    str r1, [r0]

    ldr r0, =sens_mesure
    bl encoder_read

    ldr r1, =vitesse_fronts
    str r0, [r1]

fsm_fenetre_fin:
    bx lr

.thumb_func
fsm_maj_sorties:
    push {r4, lr}

    /*rampe*/
    ldr r0, =etat
    ldr r4, [r0]
    cmp r4, #ETAT_MARCHE_AVANT
    beq fsm_rampe
    cmp r4, #ETAT_MARCHE_ARRIERE
    beq fsm_rampe
    b fsm_del

.thumb_func
fsm_rampe:
    ldr r0, =rampe_compteur
    ldr r1, [r0]
    adds r1, r1, #1
    str r1, [r0]

    cmp r1, #RAMPE_PAS_MS
    blo fsm_del

    movs r1, #0
    str r1, [r0]

    ldr r0, =pwm_pct
    ldr r1, [r0]
    ldr r2, =consigne_pct
    ldr r3, [r2]

    cmp r1, r3
    beq fsm_del

    blo fsm_rampe_up
    subs r1, r1, #1
    b fsm_rampe_write

fsm_rampe_up:
    adds r1, r1, #1

fsm_rampe_write:
    str r1, [r0]
    mov r0, r1
    bl motor_set_pwm

.thumb_func
fsm_del:
    ldr r0, =etat
    ldr r4, [r0]
    cmp r4, #ETAT_ARRET_URGENCE
    beq fsm_del_urgence

    ldr r1, =etat_vers_del
    ldrb r0, [r1, r4]
    bl led_set
    b fsm_buzzer

.thumb_func
fsm_del_urgence:
    ldr r0, =clignote_compteur
    ldr r1, [r0]
    adds r1, r1, #1
    str r1, [r0]

    cmp r1, #CLIGNOTEMENT_DEMI_MS
    blo fsm_del_phase

    movs r1, #0
    str r1, [r0]

    ldr r0, =clignote_phase
    ldr r1, [r0]
    eor r1, r1, #1
    str r1, [r0]

.thumb_func
fsm_del_phase:
    ldr r0, =clignote_phase
    ldr r1, [r0]
    cmp r1, #1
    beq fsm_del_rouge

    movs r0, #LED_AUCUNE
    bl led_set
    b fsm_buzzer

.thumb_func
fsm_del_rouge:
    movs r0, #LED_ROUGE
    bl led_set

 .thumb_func
 fsm_buzzer:
    bl buzzer_step
    pop {r4, pc}
