;------------------------- Procdure gif_load ---------------------------------
;ษออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
;บ									      บ
;บ	Entre :							      บ
;บ			AH : 1 pour internal file, 0 pour external	      บ
;บ			EDX : Offset du nom du fichier Gif		      บ
;บ			DS et ES : [Data32_Sel] 			      บ
;บ									      บ
;บ	Sortie :	þ si carry = 0 :	EAX=0			      บ
;บ			[Gif_Address] :	 Offset de l'image dcompresse	      บ
;บ					… utiliser avec Data32_Sel	      บ
;บ			[Gif_Handle] : 	 handle de la zone memoire o—	      บ
;บ					l'image dcompresse est stocke.     บ
;บ                      w[Gif_Xsize] :	 Largeur de l'image		      บ
;บ			w[Gif_Ysize] :	 Hauteur de l'image		      บ
;บ			[pal_address] : palette en 6bits prte pour sendpal   บ
;บ									      บ
;บ			þ si carry = 1 :	EAX = Code de l'erreur	      บ
;บ				1 : File Not Found			      บ
;บ				2 : Not Enough Memory to load or uncompress   บ
;บ				3 : This Is Not A Gif (Bad File Header)	      บ
;บ									      บ
;บ	  Tous Les registres sont succeptibles d'avoir chang de valeur,      บ
;บ	sauf les registres de segment et EBP.				      บ
;บ									      บ
;ศออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ

global gif_handle      :dword
global gif_load        :proc
global sendpal         :proc
global gif_address     :dword
global pal_address     :dword
global gifXsize        :word
global gifYsize        :word
global imgbits	       :byte
global ncolors	       :word
