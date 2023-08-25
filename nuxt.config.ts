// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
  modules: ['@nuxtjs/tailwindcss'],
  app: {
    head: {
      title: 'Portfolio | Winner Edwin',
      link: [
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/icon?family=Material+Icons' },
        { rel: 'stylesheet', href: 'https://fonts.googleapis.com/css2?family=Roboto' }
      ],
      meta: [
        { name: 'viewport', content: "width=device-width, initial-scale=1, user-scalable=no" }
      ]
    },
  }
})
