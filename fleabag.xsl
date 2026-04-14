<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="tei xs"
    version="2.0">
    
    <xsl:output method="html" encoding="UTF-8" indent="yes"
                doctype-system="about:legacy-compat"/>

    <!--variable-->

    <!-- Fichiers de sortie -->
    <xsl:variable name="index-file">index.html</xsl:variable>
    <xsl:variable name="script-file">script.html</xsl:variable>
    <xsl:variable name="cast-file">cast.html</xsl:variable>
    <xsl:variable name="episode-file">episode.html</xsl:variable>

    <!-- Titre principal (XPath function : normalize-space) -->
    <xsl:variable name="main-title"
        select="normalize-space(//tei:titleStmt/tei:title)"/>

    <!-- Nombre de personnages (XPath function : count) -->
    <xsl:variable name="nb-characters"
        select="count(//tei:particDesc/tei:listPerson/tei:person)"/>

    <!-- template racine -->
    <xsl:template match="/">
        <xsl:call-template name="build-index"/>
        <xsl:call-template name="build-script"/>
        <xsl:call-template name="build-cast"/>
        <xsl:call-template name="build-episode"/>
    </xsl:template>

    <!-- template réutilisable-->
    <xsl:template name="navbar">
        <xsl:param name="current"/>
        <nav class="navbar">
            <a href="{$index-file}">
                <xsl:if test="$current = 'index'">
                    <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                ACCUEIL
            </a>
            <a href="{$script-file}">
                <xsl:if test="$current = 'script'">
                    <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                SCRIPT
            </a>
            <!-- Logo centré dans la navbar (sauf sur la page d'accueil) -->
            <xsl:if test="$current != 'index'">
                <a href="{$index-file}" class="navbar-logo">Fl : le</a>
            </xsl:if>
            <a href="{$cast-file}">
                <xsl:if test="$current = 'cast'">
                    <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                CAST
            </a>
            <a href="{$episode-file}">
                <xsl:if test="$current = 'episode'">
                    <xsl:attribute name="class">active</xsl:attribute>
                </xsl:if>
                EPISODE
            </a>
        </nav>
    </xsl:template>

    <xsl:template name="html-head">
        <xsl:param name="page-title"/>
        <head>
            <meta charset="UTF-8"/>
            <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
            <title><xsl:value-of select="$page-title"/></title>
            <link rel="stylesheet" href="style.css"/>
        </head>
    </xsl:template>

    <xsl:template name="footer">
        <footer>
            <!-- Fonctions XPath : string(), concat() -->
            <p>
                <xsl:value-of select="concat(
                    normalize-space(//tei:titleStmt/tei:author/tei:persName/tei:forename),
                    ' ',
                    normalize-space(//tei:titleStmt/tei:author/tei:persName/tei:surname)
                )"/>
                — <xsl:value-of select="normalize-space(//tei:publicationStmt/tei:pubPlace)"/>
                — <xsl:value-of select="normalize-space(//tei:publicationStmt/tei:date)"/>
            </p>
            <p>
                <a href="{normalize-space(//tei:publicationStmt//tei:ref/@target)}"
                   target="_blank" rel="noreferrer">
                    <xsl:value-of select="normalize-space(//tei:publicationStmt//tei:ref)"/>
                </a>
            </p>
        </footer>
    </xsl:template>

    <!-- index -->
    <xsl:template name="build-index">
        <xsl:result-document href="{$index-file}" method="html" encoding="UTF-8">
            <html lang="fr">
                <xsl:call-template name="html-head">
                    <xsl:with-param name="page-title" select="$main-title"/>
                </xsl:call-template>
                <body class="page-index">

                    <!-- Navigation sans logo -->
                    <nav class="navbar navbar-home">
                        <a href="{$index-file}" class="active">ACCUEIL</a>
                        <a href="{$script-file}">SCRIPT</a>
                        <a href="{$cast-file}">CAST</a>
                        <a href="{$episode-file}">EPISODE</a>
                    </nav>

                    <header class="hero">
                        <h1 class="hero-title">Fleabag :<br/>
                            <span class="hero-subtitle">the encoding</span>
                        </h1>
                        <img src="img/posterEB.jpg"
                             alt="Portrait Fleabag — peinture"
                             class="hero-painting"/>
                    </header>

                    <!-- Section d'introduction : données du teiHeader -->
                    <main class="index-main">

                        <!-- Présentation du projet -->
                        <section class="section-intro">
                            <p class="intro-text">
                                <xsl:value-of
                                    select="normalize-space(//tei:encodingDesc/tei:projectDesc/tei:p)"/>
                            </p>
                        </section>

                        <!-- Métadonnées bibliographiques (boucle sur les bibl) -->
                        <!-- BOUCLE xsl:for-each sur les sources bibliographiques -->
                        <section class="section-sources">
                            <h2>Sources</h2>
                            <xsl:for-each select="//tei:sourceDesc/tei:bibl">
                                <div class="bibl-card">
                                    <!-- CONDITION : distingue livre et ressource en ligne -->
                                    <xsl:choose>
                                        <xsl:when test="@type = 'book'">
                                            <span class="bibl-type">📖 Publication imprimée</span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="bibl-type">🌐 Ressource en ligne</span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    <p class="bibl-title">
                                        <em><xsl:value-of select="normalize-space(tei:title)"/></em>
                                    </p>
                                    <!-- Auteur s'il existe (prédicat : bibl qui contient author) -->
                                    <xsl:if test="tei:author">
                                        <p class="bibl-author">
                                            <xsl:value-of select="concat(
                                                normalize-space(tei:author/tei:persName/tei:forename),
                                                ' ',
                                                normalize-space(tei:author/tei:persName/tei:surname)
                                            )"/>
                                        </p>
                                    </xsl:if>
                                    <xsl:if test="tei:publisher">
                                        <p class="bibl-publisher">
                                            <xsl:value-of select="normalize-space(tei:publisher)"/>
                                            <xsl:if test="tei:pubPlace">
                                                , <xsl:value-of select="normalize-space(tei:pubPlace)"/>
                                            </xsl:if>
                                        </p>
                                    </xsl:if>
                                    <xsl:if test="tei:date">
                                        <p class="bibl-date">
                                            <xsl:value-of select="normalize-space(tei:date)"/>
                                        </p>
                                    </xsl:if>
                                    <xsl:if test="tei:idno[@type='ISBN']">
                                        <p class="bibl-isbn">
                                            ISBN : <xsl:value-of select="normalize-space(tei:idno[@type='ISBN'])"/>
                                        </p>
                                    </xsl:if>
                                </div>
                            </xsl:for-each>
                        </section>

                        <!-- Données de création (director, writer) -->
                        <section class="section-creation">
                            <h2>Création</h2>
                            <ul class="creation-list">
                                <!-- BOUCLE sur persNames de création -->
                                <xsl:for-each select="//tei:profileDesc/tei:creation/tei:persName">
                                    <li>
                                        <!-- CONDITION sur le rôle -->
                                        <xsl:choose>
                                            <xsl:when test="@role = 'directeur'">
                                                <span class="role-label">Réalisateur</span>
                                            </xsl:when>
                                            <xsl:when test="@role = 'writter'">
                                                <span class="role-label">Scénariste</span>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <span class="role-label">
                                                    <xsl:value-of select="@role"/>
                                                </span>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <span class="role-name">
                                            <xsl:value-of select="concat(
                                                normalize-space(tei:forename), ' ',
                                                normalize-space(tei:surname))"/>
                                        </span>
                                    </li>
                                </xsl:for-each>
                            </ul>
                            <p class="broadcast-date">
                                Diffusé le :
                                <xsl:value-of
                                    select="normalize-space(//tei:creation/tei:date[@type='publication'])"/>
                            </p>
                        </section>

                        <!-- Liens vers les autres pages -->
                        <section class="section-nav-cards">
                            <a href="{$script-file}" class="nav-card">
                                <span class="nav-card-icon">✒</span>
                                <span class="nav-card-label">Script</span>
                                <span class="nav-card-desc">Lire le texte encodé</span>
                            </a>
                            <a href="{$cast-file}" class="nav-card">
                                <span class="nav-card-icon">◈</span>
                                <span class="nav-card-label">Cast</span>
                                <!-- Fonction XPath : string() + count() -->
                                <span class="nav-card-desc">
                                    <xsl:value-of select="concat(
                                        string($nb-characters),
                                        ' personnages encodés'
                                    )"/>
                                </span>
                            </a>
                            <a href="{$episode-file}" class="nav-card">
                                <span class="nav-card-icon">▶</span>
                                <span class="nav-card-label">Épisode</span>
                                <span class="nav-card-desc">Saison 2 — Épisode 1</span>
                            </a>
                        </section>

                    </main>

                    <div class="guinea-container">
                        <img src="img/guinea.jpeg" alt="Hilary le cochon d'Inde" class="guinea-img"/>
                    </div>

                    <xsl:call-template name="footer"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <!-- script.html-->
    <xsl:template name="build-script">
        <xsl:result-document href="{$script-file}" method="html" encoding="UTF-8">
            <html lang="fr">
                <xsl:call-template name="html-head">
                    <xsl:with-param name="page-title">Script — <xsl:value-of select="$main-title"/></xsl:with-param>
                </xsl:call-template>
                <body class="page-script">
                    <xsl:call-template name="navbar">
                        <xsl:with-param name="current">script</xsl:with-param>
                    </xsl:call-template>

                    <main class="script-main">
                        <h2 class="script-head">transcription</h2>
                        <h3 class="script-subhead">Episode 1 Saison 2</h3>

                        <!-- Contenu du script : boucle sur les enfants du div principal -->
                        <div class="script-content">
                            <xsl:apply-templates
                                select="//tei:body/tei:div[tei:stage or tei:sp or tei:view or tei:sound or tei:ab]/*"/>
                        </div>

                        <!-- Lien hypertexte vers le cast (autre que navbar) -->
                        <div class="script-link-cast">
                            → Découvrir les personnages sur la page
                            <a href="{$cast-file}">Cast</a>
                        </div>
                    </main>

                    <xsl:call-template name="footer"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


    <!-- Indication scénique (stage) -->
    <xsl:template match="tei:stage">
        <p class="stage">
            <!-- CONDITION : type de stage (setting = lieu, delivery = jeu, etc.) -->
            <xsl:choose>
                <xsl:when test="@type = 'setting'">
                    <span class="stage-label stage-setting">LIEU</span>
                </xsl:when>
                <xsl:when test="@type = 'delivery'">
                    <span class="stage-label stage-delivery">JEU</span>
                </xsl:when>
                <xsl:when test="@type = 'address'">
                    <span class="stage-label stage-address">ADRESSE</span>
                </xsl:when>
                <xsl:when test="@type = 'timing'">
                    <span class="stage-label stage-timing">TIMING</span>
                </xsl:when>
                <xsl:when test="@type = 'entrance'">
                    <span class="stage-label stage-entrance">ENTRÉE</span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="@type">
                        <span class="stage-label">
                            <xsl:value-of select="upper-case(@type)"/>
                        </span>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Son / musique -->
    <xsl:template match="tei:sound">
        <p class="sound">
            <span class="sound-icon">♪</span>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Description visuelle -->
    <xsl:template match="tei:view">
        <p class="view">
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Réplique -->
    <xsl:template match="tei:sp">
        <div class="speech">
            <!-- PRÉDICAT : speeches adressés au public (to-camera) -->
            <xsl:if test="@toWhom = 'public'">
                <xsl:attribute name="class">speech speech-to-camera</xsl:attribute>
            </xsl:if>
            <!-- Hors-champ -->
            <xsl:if test="@rend = 'off screen'">
                <xsl:attribute name="class">speech speech-offscreen</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Nom du locuteur -->
    <xsl:template match="tei:speaker">
        <span class="speaker">
            <!-- CONDITION : speaker avec référence vers un personnage -->
            <xsl:choose>
                <xsl:when test="@corresp">
                    <!-- FONCTION XPath : substring-after pour extraire l'id -->
                    <xsl:variable name="char-id"
                        select="substring-after(@corresp, '#')"/>
                    <!-- Lien vers la fiche personnage dans cast.html -->
                    <a href="{$cast-file}#{$char-id}" class="speaker-link">
                        <xsl:apply-templates/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>

    <!-- Réplique proprement dite -->
    <xsl:template match="tei:sp/tei:p">
        <p class="line"><xsl:apply-templates/></p>
    </xsl:template>

    <!-- Référence à un personnage dans les stage directions / views -->
    <xsl:template match="tei:ref[@corresp]">
        <xsl:variable name="ref-id" select="substring-after(@corresp, '#')"/>
        <a href="{$cast-file}#{$ref-id}" class="char-ref">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- Balise ab (titre de séquence) -->
    <xsl:template match="tei:ab">
        <p class="ab"><xsl:apply-templates/></p>
    </xsl:template>

    <!-- Caption -->
    <xsl:template match="tei:caption">
        <span class="caption"><xsl:apply-templates/></span>
    </xsl:template>

    <!-- Camera -->
    <xsl:template match="tei:camera">
        <span class="camera"><xsl:apply-templates/></span>
    </xsl:template>

    <!-- Tech (montage etc.) -->
    <xsl:template match="tei:tech">
        <span class="tech"><xsl:value-of select="upper-case(@type)"/></span>
    </xsl:template>

    <!-- Tête de section dans le body -->
    <xsl:template match="tei:body/tei:div/tei:head"/>
    <!-- (géré directement dans build-script) -->

    <!-- cast.html-->
    <xsl:template name="build-cast">
        <xsl:result-document href="{$cast-file}" method="html" encoding="UTF-8">
            <html lang="fr">
                <xsl:call-template name="html-head">
                    <xsl:with-param name="page-title">Cast — <xsl:value-of select="$main-title"/></xsl:with-param>
                </xsl:call-template>
                <body class="page-cast">
                    <xsl:call-template name="navbar">
                        <xsl:with-param name="current">cast</xsl:with-param>
                    </xsl:call-template>

                    <main class="cast-main">
                        <h1 class="cast-title">casting</h1>

                        <!-- BOUCLE sur tous les personnages -->
                        <xsl:for-each select="//tei:particDesc/tei:listPerson/tei:person">
                            <!-- Tri : personnages principaux d'abord -->
                            <xsl:sort select="tei:state/@subtype" order="ascending"/>

                            <!-- PRÉDICAT : séparer personnages principaux et secondaires -->
                            <xsl:variable name="is-main"
                                select="tei:state[@subtype = 'main']"/>
                            <xsl:variable name="char-id" select="@xml:id"/>
                            <xsl:variable name="char-name"
                                select="normalize-space(tei:state/tei:label)"/>
                            <xsl:variable name="actor-name"
                                select="concat(
                                    normalize-space(tei:persName/tei:forename),
                                    ' ',
                                    normalize-space(tei:persName/tei:surname)
                                )"/>

                            <article class="char-card" id="{$char-id}">
                                <!-- Photo du personnage (nom.png) -->
                                <div class="char-img-wrap">
                                    <img class="char-img" alt="{$char-name}">
                                        <xsl:attribute name="src">
                                            <xsl:choose>
                                                <xsl:when test="$char-id = 'F'">img/flea.png</xsl:when>
                                                <xsl:when test="$char-id = 'C'">img/claire.png</xsl:when>
                                                <xsl:when test="$char-id = 'P'">img/priest.png</xsl:when>
                                                <xsl:when test="$char-id = 'D'">img/dad.png</xsl:when>
                                                <xsl:when test="$char-id = 'G'">img/godmother.png</xsl:when>
                                                <xsl:when test="$char-id = 'M'">img/martin.png</xsl:when>
                                                <xsl:when test="$char-id = 'B'">img/boo.png</xsl:when>
                                                <xsl:when test="$char-id = 'AG'">img/arshole.png</xsl:when>
                                                <xsl:otherwise>img/fleabag.png</xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:attribute>
                                    </img>
                                </div>

                                <div class="char-info">
                                    <!-- Nom du personnage en script font -->
                                    <h2 class="char-name">
                                        <xsl:value-of select="$char-name"/>
                                    </h2>

                                    <!-- Acteur·rice -->
                                    <p class="actor-name">
                                        interprété·e par <em><xsl:value-of select="$actor-name"/></em>
                                    </p>

                                    <!-- Badge principal / secondaire -->
                                    <xsl:choose>
                                        <xsl:when test="$is-main">
                                            <span class="badge badge-main">Personnage principal</span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="badge badge-supporting">Personnage secondaire</span>
                                        </xsl:otherwise>
                                    </xsl:choose>

                                    <!-- Genre (CONDITION sur @gender) -->
                                    <xsl:if test="@gender">
                                        <span class="badge badge-gender">
                                            <xsl:choose>
                                                <xsl:when test="@gender = 'W'">F</xsl:when>
                                                <xsl:when test="@gender = 'M'">M</xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="@gender"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </span>
                                    </xsl:if>

                                    <!-- Description du personnage -->
                                    <p class="char-desc">
                                        <xsl:value-of
                                            select="normalize-space(tei:state/tei:desc)"/>
                                    </p>

                                    <!-- Source de la description -->
                                    <xsl:if test="tei:state/tei:desc/@source">
                                        <a href="{tei:state/tei:desc/@source}"
                                           class="char-source" target="_blank" rel="noreferrer">
                                            Fiche wiki ↗
                                        </a>
                                    </xsl:if>

                                    <!-- Lien vers les répliques du personnage dans le script -->
                                    <a href="{$script-file}" class="char-script-link">
                                        → Voir les répliques dans le script
                                    </a>
                                </div>
                            </article>
                        </xsl:for-each>

                        <!-- Statistiques de distribution -->
                        <section class="cast-stats">
                            <p>
                                <!-- FONCTION XPath count() + string() -->
                                <xsl:value-of select="concat(
                                    string($nb-characters), ' personnages encodés — ',
                                    string(count(//tei:person[@gender='W'])), ' femmes, ',
                                    string(count(//tei:person[@gender='M'])), ' hommes'
                                )"/>
                            </p>
                        </section>
                    </main>

                    <xsl:call-template name="footer"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <!--episode.html-->
    <xsl:template name="build-episode">
        <xsl:result-document href="{$episode-file}" method="html" encoding="UTF-8">
            <html lang="fr">
                <xsl:call-template name="html-head">
                    <xsl:with-param name="page-title">Épisode — <xsl:value-of select="$main-title"/></xsl:with-param>
                </xsl:call-template>
                <body class="page-episode">
                    <xsl:call-template name="navbar">
                        <xsl:with-param name="current">episode</xsl:with-param>
                    </xsl:call-template>

                    <main class="episode-main">

                        <h1 class="episode-heading">saison 2 episode 1</h1>

                        <!-- Vidéo de l'épisode -->
                        <div class="video-wrap">
                            <video controls="controls" poster="img/posterEB.jpg" class="episode-video">
                                <source src="img/fleabag.s2e1.mkv" type="video/x-matroska"/>
                                <p>Votre navigateur ne supporte pas la lecture vidéo.</p>
                            </video>
                        </div>

                        <!-- Métadonnées de l'épisode -->
                        <section class="episode-meta">
                            <dl class="meta-list">
                                <dt>Canal</dt>
                                <dd>
                                    <xsl:value-of
                                        select="normalize-space(//tei:textDesc/tei:channel)"/>
                                </dd>

                                <dt>Factualité</dt>
                                <dd>
                                    <xsl:value-of
                                        select="normalize-space(//tei:textDesc/tei:factuality)"/>
                                </dd>

                                <dt>Préparation</dt>
                                <dd>
                                    <xsl:value-of
                                        select="normalize-space(//tei:textDesc/tei:preparedness)"/>
                                </dd>

                                <dt>Note IMDB</dt>
                                <dd>
                                    <xsl:value-of
                                        select="normalize-space(//tei:textDesc/tei:interaction)"/>
                                    <xsl:text> </xsl:text>
                                    <a href="{//tei:textDesc/tei:interaction/@source}"
                                       target="_blank" rel="noreferrer"
                                       class="imdb-link">↗ IMDB</a>
                                </dd>

                                <dt>Objet</dt>
                                <dd>
                                    <xsl:value-of
                                        select="normalize-space(//tei:textDesc/tei:purpose)"/>
                                </dd>

                            </dl>
                        </section>

                    </main>

                    <xsl:call-template name="footer"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

</xsl:stylesheet>
