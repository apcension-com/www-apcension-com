---
layout: archive
title: "Articles"
permalink: /articles/
author_profile: true
header:
  overlay_image: /assets/images/blogheader.jpg
  caption: "Photo credit: [**Pexels**](https://pexels.com)"
  #feature_row:
  #- image_path: assets/images/unsplash-gallery-image-1-th.jpg
  #  alt: "placeholder image 1"
  #  title: "Placeholder 1"
  #  excerpt: "This is some sample content that goes here with **Markdown** formatting."
  #- image_path: /assets/images/unsplash-gallery-image-2-th.jpg
  #  alt: "placeholder image 2"
  #  title: "Placeholder 2"
  #  excerpt: "This is some sample content that goes here with **Markdown** formatting."
  #  url: "#test-link"
  #  btn_label: "Read More"
  #  btn_class: "btn--primary"
  #- image_path: /assets/images/unsplash-gallery-image-3-th.png
  #  title: "Placeholder 3"
  #  excerpt: "This is some sample content that goes here with **Markdown** formatting."
feature_row2:
  - image_path: /assets/images/unsplash-gallery-image-2-th.jpg
    alt: "Oh Crypto"
    title: "Oh Crypto"
    excerpt: 'Available now at an App Store near you!'
    url: /articles/Oh-Crypto/
    btn_label: "Read More"
    btn_class: "btn--primary"
feature_row3:
  - image_path: /assets/images/unsplash-gallery-image-1-th.jpg
    alt: "placeholder image 2"
    title: "Broadband Deployment"
    excerpt: 'The FCC stands for the Federal Communications Commission.'
    url: /articles/Broadband/
    btn_label: "Read More"
    btn_class: "btn--primary"
feature_row4:
  - image_path: /assets/images/unsplash-image-gallery-6-th.png
    alt: "placeholder image 2"
    title: "Packer with Hyper-V"
    excerpt: 'HashiCorp has been an amazingly disruptive force in the DevOps world - for the better.'
    url: /articles/Packer/
    btn_label: "Read More"
    btn_class: "btn--primary"
feature_row5:
  - image_path: /assets/images/unsplash-image-gallery-7-th.jpg
    alt: "placeholder image 2"
    title: "Net Neutrality"
    excerpt: 'By definition net neutrality is “the principle that Internet service providers should enable access to all content and applications regardless of the source, and without favoring or blocking particular products or websites".'
    url: /articles/Net/
    btn_label: "Read More"
    btn_class: "btn--primary"
feature_row6:
  - image_path: /assets/images/unsplash-image-gallery-8-th.jpg
    alt: "placeholder image 2"
    title: "Windows 10 Install Fun"
    excerpt: 'Stumbled across an annoying little issue the other morning performing a reload of Windows 10 on to an existing Lab setup for a client.'
    url: /articles/Windows/
    btn_label: "Read More"
    btn_class: "btn--primary"
---

{% for post in site.posts limit: 10 %}

{% endfor %}

{% include feature_row %}

{% include feature_row id="feature_row2" type="left" %}

{% include feature_row id="feature_row3" type="right" %}

{% include feature_row id="feature_row4" type="left" %}

{% include feature_row id="feature_row5" type="right" %}

{% include feature_row id="feature_row6" type="left" %}
