%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% File:     aghdpl.cls           (LaTeX Document class option "aghdpl")
%          
% Author:  Marcin Szpyrka     (mszpyrka@agh.edu.pl)
%          Grzegorz J. Nalepa (gjn@agh.edu.pl)
%          AGH University of Science and Technology, Kraków, POLAND
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\message{*** [aghdpl.cls] ---  (MSz, GJN)  v0.22 <05.04.2011>  ***}       

\newif\ifpdflatex\pdflatexfalse
\NeedsTeXFormat{LaTeX2e} % 
\ProvidesClass{aghdpl} 
\DeclareOption{pdflatex}{\pdflatextrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{report}} 
\ProcessOptions\LoadClass[a4paper,oneside]{report} 

\RequirePackage{times}
\RequirePackage[T1]{fontenc}
\RequirePackage{graphicx}
\RequirePackage{geometry}
\RequirePackage[usenames]{color}
\RequirePackage{fancyhdr}
\RequirePackage{url}
\RequirePackage{titlesec}
\RequirePackage{tocloft}
\RequirePackage[utf8]{inputenc}

% Customised
\RequirePackage{enumerate}
\RequirePackage{listings}
\RequirePackage{tabularx}
\RequirePackage{amsfonts}
\RequirePackage{amsmath}
\RequirePackage{ctable}
\RequirePackage{courier}
\RequirePackage{caption}
\RequirePackage{paralist}

\lstset{
         basicstyle=\footnotesize\ttfamily, % Standardschrift
         %numbers=left,               % Ort der Zeilennummern
         numberstyle=\tiny,          % Stil der Zeilennummern
         %stepnumber=2,               % Abstand zwischen den Zeilennummern
         numbersep=5pt,              % Abstand der Nummern zum Text
         tabsize=2,                  % Groesse von Tabs
         extendedchars=true,         %
         breaklines=true,            % Zeilen werden Umgebrochen
         keywordstyle=\color{red},
    		frame=b,         
 %        keywordstyle=[1]\textbf,    % Stil der Keywords
 %        keywordstyle=[2]\textbf,    %
 %        keywordstyle=[3]\textbf,    %
 %        keywordstyle=[4]\textbf,   \sqrt{\sqrt{}} %
         stringstyle=\color{white}\ttfamily, % Farbe der String
         showspaces=false,           % Leerzeichen anzeigen ?
         showtabs=false,             % Tabs anzeigen ?
         xleftmargin=17pt,
         framexleftmargin=17pt,
         framexrightmargin=5pt,
         framexbottommargin=4pt,
         %backgroundcolor=\color{lightgray},
         showstringspaces=false      % Leerzeichen in Strings anzeigen ?        
 }
 \lstloadlanguages{% Check Dokumentation for further languages ...
         %[Visual]Basic
         %Pascal
         %C
         %C++
         %XML
         %HTML
         Java
 }
%\DeclareCaptionFont{blue}{\color{blue}} 
%\captionsetup[lstlisting]{singlelinecheck=false, labelfont={blue}, textfont={blue}}

\DeclareCaptionFont{white}{\color{white}}
\DeclareCaptionFormat{listing}{\colorbox[RGB]{100, 98, 102}{\parbox{\textwidth}{\hspace{15pt}#1#2#3}}}
\captionsetup[lstlisting]{format=listing,labelfont=white,textfont=white, singlelinecheck=false, margin=0pt, font={bf,footnotesize}}



\geometry{lmargin=30mm, rmargin=20mm, tmargin=25mm, bmargin=25mm, foot=10mm, head=10mm}
\definecolor{Green}{rgb}{0.1,0.5,0.1}

\def\shorttitlePL#1   {\gdef\@shorttitlePL{#1}}
\def\shorttitleEN#1   {\gdef\@shorttitleEN{#1}}
\def\shortauthor#1    {\gdef\@shortauthor{#1}}
\def\titlePL#1        {\gdef\@titlePL{#1}}
\def\titleEN#1        {\gdef\@titleEN{#1}}
\def\facultyEN#1      {\gdef\@facultyEN{#1}}
\def\facultyPL#1      {\gdef\@facultyPL{#1}}
\def\thesistypePL#1   {\gdef\@thesistypePL{#1}}
\def\thesistypeEN#1   {\gdef\@thesistypeEN{#1}}
\def\supervisorPL#1   {\gdef\@supervisorPL{#1}}
\def\supervisorEN#1   {\gdef\@supervisorEN{#1}}
\def\acknowledgements#1   {\gdef\@acknowledgements{#1}}
\def\departmentPL#1   {\gdef\@departmentPL{#1}}
\def\departmentEN#1   {\gdef\@departmentEN{#1}}

% \thesisheaders
% 
% \pagestyle{fancy}

%\bibliographystyle{abbrv}
\linespread{1.3}
\renewcommand{\labelitemi}{--}

%------------------------------------------------------------------------------

\newcommand{\chapterintro}[1] {
  \emph{#1}
  \vspace*{0.5cm}
}

\def\displayauthors{
  {
    \setlength{\baselineskip}{1.5\baselineskip}
    {\LARGE \textsc \@author}
  \par}
  \vspace*{3.5cm}
}

\newcommand{\titlepages}{%

\newpage \titlepage 

%% English front page
\begin{center}

\includegraphics[scale=0.35]{agh}
\vspace*{0.5cm}

{
  \sffamily{
    \bfseries{
      \Large{
        University of Science and Technology in Krakow
      } \\ 
    \vspace{5mm}
    \large \@facultyEN \\
    \large \@departmentEN
    }
  }
}


\vspace{3cm}

{
  \setlength{\baselineskip}{2\baselineskip}
  {
    \Huge{
      \@titleEN
    }
  }
\par}

\vspace*{3cm}


\displayauthors
\begin{flushright}
  \large Supervised by { \scshape \@supervisorEN} \\
  \large Assistant Professor of Computer Science
\end{flushright}

\vfill{\Large Krakow \@date}

\end{center}

%% End of English front-page


%% Statements
\clearpage \titlepage \vspace*{15cm} \vfill

\begin{flushright}
\begin{minipage}[!h]{12cm}
\large Oświadczamy, świadomi odpowiedzialności karnej za poświadczenie nieprawdy, że niniejszą pracę dyplomową wykonaliśmy osobiście i~samodzielnie (w zakresie wyszczególnionym we wstępie) i~że nie korzystaliśmy ze źródeł innych niż wymienione w~pracy.
\end{minipage}

\vspace{2cm}

\makebox[6cm][s]{\dotfill}\par
\makebox[6cm][c]{\small PODPIS}

\end{flushright}

\clearpage \titlepage
%% End of statements


%% Polish front page
\begin{center}

\includegraphics[scale=0.35]{agh}
\vspace*{0.5cm}

{
  \sffamily{
    \bfseries{
      \Large{
        Akademia Górniczo-Hutnicza im. Stanisława Staszica w Krakowie
      } \\ 
    \vspace{5mm}
    \large \@facultyPL \\
    \large \@departmentPL
    }
  }
}

\vspace{3cm}

{
  \setlength{\baselineskip}{2\baselineskip}
  {
    \Huge{
      \@titlePL
    }
  }
\par}

\vspace*{3cm}

\displayauthors

\begin{flushright}
  \large  Promotor:{ \@supervisorPL} 
\end{flushright}

\vfill{\Large Krakow \@date}

\end{center}

\clearpage \titlepage

%% End of Polish frontpage

\vspace*{15cm} \vfill
\begin{flushright} 
\begin{minipage}[!h]{8cm}
{\Large \@acknowledgements}
\end{minipage}
\end{flushright}

\clearpage \titlepage

\include{abstract}

\clearpage

\setcounter{page}{5}

}

\def\thesisheaders{

}

\DeclareOption{en}{
\def\thesisheaders{

}
}

\ProcessOptions

\pagestyle{fancy}
\renewcommand{\chaptermark}[1]{\markboth{\thechapter.\ #1}{}}
\renewcommand{\sectionmark}[1]{\markright{\thesection.\ #1}}
\renewcommand{\headrulewidth}{0.5pt}
\renewcommand{\footrulewidth}{0pt}
\fancyhf{}
\fancyfoot{}
\fancyhead[L]{\slshape{\small \rightmark}}
\fancyhead[R]{\bfseries \thepage}

\thesisheaders

\frenchspacing
\sloppy 
\widowpenalty     9999 
\clubpenalty      9999 
\flushbottom

%---------------------------------------------------------------------------
% Ustawienia parametrów dla tytułów rozdziałów, podrozdziałów, itd.
%---------------------------------------------------------------------------


\titleformat{\chapter}[block]
{\bfseries\LARGE}{\filright \LARGE\thechapter. }{0ex}{}
%odstępy: lewy, góra, dół
\titlespacing{\chapter}{0pt}{17mm}{19mm}
\titleformat{\section}[block]
{\bfseries\Large}{\filright \Large\thesection. }{0ex}{}
\titlespacing{\section}{7mm}{8mm plus 0mm minus 1mm}{4mm plus 0mm minus 1mm}
\titleformat{\subsection}[block]
{\bfseries\large}{\filright \large\thesubsection. }{0ex}{}
\titlespacing{\subsection}{7mm}{6mm}{2.5mm}
\titleformat{\subsubsection}[block]
{\bfseries\normalsize}{\filright \normalsize\thesubsubsection. }{0ex}{}
\titlespacing{\subsubsection}{7mm}{3mm}{1.5mm}

%---------------------------------------------------------------------------
% Ustawienia parametrów generowania spisu treści i spisu rysunków
%---------------------------------------------------------------------------

\renewcommand{\cfttoctitlefont}{\bfseries\Large}
\renewcommand{\cftbeforetoctitleskip}{20mm}
\renewcommand{\cftaftertoctitleskip}{19mm}
\renewcommand{\cftchapleader}{\cftdotfill{\cftdot}}
\renewcommand{\cftsecleader}{\cftdotfill{\cftdot}}
\renewcommand{\cftsubsecleader}{\cftdotfill{\cftdot}}
\renewcommand{\cftchapaftersnum}{.}
\renewcommand{\cftsecaftersnum}{.}
\renewcommand{\cftsubsecaftersnum}{.}
\setlength{\cftparskip}{2pt}
\setlength{\cftbeforechapskip}{0mm}
\renewcommand{\cftchappagefont}{\normalsize}
