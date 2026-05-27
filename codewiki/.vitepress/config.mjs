import { withMermaid } from 'vitepress-plugin-mermaid'

export default withMermaid({
  lang: 'id-ID',
  title: 'SmartAI Chat',
  description: 'Dokumentasi SmartAI Chat — Flutter + Forui + Riverpod',
  themeConfig: {
    sidebar: (await import('./sidebar.mjs')).default,
    socialLinks: [
      { icon: 'github', link: 'https://github.com/smartai/smartai_chat' }
    ]
  }
})
