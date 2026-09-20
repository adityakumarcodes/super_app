import { createFileRoute } from '@tanstack/react-router'
import { BookText, Camera, Heart, MessageCircle, Plus, Search, Sparkles, Utensils } from 'lucide-react'

export const Route = createFileRoute('/social')({
  component: RouteComponent,
})

const circles = ['#sourcejourney', '#localgrocer', '#simpleplates', '#seasonalcooking']

const members = ['Alice Vance', 'Robert Frost', 'Lana Del', 'Chef Pierre']

const posts = [
  {
    name: 'Elena Petrova',
    role: 'Artisan Baker',
    time: '2 hours ago',
    text: 'Just baked a fresh batch of pain de campagne! Sourdough culture is healthy, happy, and bubbly. Swipe to see the crumb texture.',
    image:
      'https://images.unsplash.com/photo-1509440159596-0249088772ff?auto=format&fit=crop&w=1200&q=80',
    likes: 42,
    comments: 7,
  },
  {
    name: 'Marcus Chen',
    role: 'Healthy Eater',
    time: '5 hours ago',
    text: 'Tried out the heirloom tomatoes from the local grocer on the app. Paired with fresh burrata and basil oil. Simple, pure food.',
    image: null,
    likes: 18,
    comments: 4,
  },
]

function RouteComponent() {
  return (
    <div className="min-h-screen bg-[#f5f3f0] px-4 py-6 text-[#1f1f1f]">
      <div className="mx-auto flex max-w-[1440px] gap-8">
        <aside className="w-[260px] rounded-r-[24px] border-r border-[#d7d1c8] bg-[#f3f0ed] p-6 pl-5">
          <div className="mb-10 flex items-center gap-3">
            <div className="flex h-10 w-10 items-center justify-center rounded-full theme-accent-soft text-lg font-medium text-[#1f1f1f] shadow-sm">
              F
            </div>
            <h2 className="text-[2.2rem] leading-none text-[#1f1f1f]">Social</h2>
          </div>

          <div className="mb-8">
            <p className="mb-3 text-xs font-medium uppercase tracking-[0.18em] text-[#6d6661]">
              Explore circles
            </p>
            <div className="space-y-2">
              {[
                { label: 'All Feed', active: true, icon: BookText },
                { label: 'Baking & Doughs', active: false, icon: Utensils },
                { label: 'Organic Sourcing', active: false, icon: Sparkles },
                { label: 'Weekly Recipes', active: false, icon: Search },
              ].map(({ label, active, icon: Icon }) => (
                <button
                  key={label}
                  className={`flex w-full items-center gap-3 rounded-full border border-[#282424] px-3 py-2 text-left text-[1.06rem] transition ${active ? 'theme-accent-bg shadow-[inset_0_0_0_1px_rgba(0,0,0,0.2)]' : 'bg-transparent hover:bg-white/60'
                    }`}
                >
                  <span className="inline-flex h-6 w-6 items-center justify-center rounded-full bg-transparent">
                    <Icon size={18} strokeWidth={1.8} />
                  </span>
                  {label}
                </button>
              ))}
            </div>
          </div>

          <div>
            <p className="mb-3 text-xs font-medium uppercase tracking-[0.18em] text-[#6d6661]">
              Trending hashtags
            </p>
            <div className="space-y-1 text-[1.05rem] text-[#1c1a1a]">
              {circles.map((tag) => (
                <div key={tag} className="py-1">
                  {tag}
                </div>
              ))}
            </div>
          </div>
        </aside>

        <main className="flex-1 max-w-[760px]">
          <div className="rounded-[26px] border border-[#2a2928] bg-[#f9f5f1] p-5 shadow-[0_0_0_1px_rgba(0,0,0,0.05)]">
            <div className="flex items-center gap-3 rounded-[22px] border border-[#2a2928] bg-[#f9f5f1] p-3">
              <div className="h-9 w-9 rounded-full theme-accent-soft" />
              <input
                value="Share your fresh culinary creations today..."
                readOnly
                className="flex-1 bg-transparent text-[1.06rem] text-[#5b5048] outline-none"
              />
            </div>

            <div className="mt-4 flex items-center gap-3">
              <button className="flex items-center gap-2 rounded-full border border-[#2a2928] bg-transparent px-4 py-2 text-[1.02rem] text-[#1f1f1f]">
                <Camera size={18} />
                Photo
              </button>
              <button className="flex items-center gap-2 rounded-full border border-[#2a2928] bg-transparent px-4 py-2 text-[1.02rem] text-[#1f1f1f]">
                <Plus size={18} />
                Tag recipe
              </button>
              <button className="ml-auto rounded-full border border-[#2a2928] theme-accent-bg px-5 py-2 text-[1.02rem] font-medium">
                Share post
              </button>
            </div>
          </div>

          <div className="mt-6 space-y-6">
            {posts.map((post) => (
              <article key={post.name} className="rounded-[26px] border border-[#2a2928] bg-[#f9f5f1] p-5 shadow-[0_0_0_1px_rgba(0,0,0,0.05)]">
                <header className="mb-4 flex items-center justify-between gap-4">
                  <div className="flex items-center gap-3">
                    <div className="h-11 w-11 rounded-full bg-[radial-gradient(circle_at_30%_30%,#e8d7c2,#6a5649_65%,#2d2a2a)]" />
                    <div>
                      <div className="text-[1.02rem] font-medium text-[#1b1a1a]">{post.name}</div>
                      <div className="text-sm text-[#6b645f]">
                        {post.role} • {post.time}
                      </div>
                    </div>
                  </div>
                  <div className="text-xl text-[#1f1f1f]">⋯</div>
                </header>

                <p className="mb-4 text-[1.02rem] leading-7 text-[#23211f]">{post.text}</p>

                {post.image && (
                  <div
                    className="mb-4 h-[420px] overflow-hidden rounded-[18px] bg-cover bg-center"
                    style={{ backgroundImage: `url(${post.image})` }}
                  />
                )}

                <div className="flex items-center gap-5 text-[#1e1d1d]">
                  <button className="inline-flex items-center gap-2">
                    <Heart size={16} strokeWidth={1.8} />
                    <span>{post.likes}</span>
                  </button>
                  <button className="inline-flex items-center gap-2">
                    <MessageCircle size={16} strokeWidth={1.8} />
                    <span>{post.comments}</span>
                  </button>
                </div>
              </article>
            ))}
          </div>
        </main>

        <aside className="w-[300px] pt-3">
          <div className="mb-8 rounded-[22px] border border-[#2a2928] bg-[#f9f5f1] p-4">
            <div className="mb-4 text-right text-[0.72rem] font-medium uppercase tracking-[0.18em] text-[#625d5a]">
              Members online
            </div>
            <div className="space-y-4">
              {members.map((member) => (
                <div key={member} className="flex items-center gap-3 text-[1.02rem] text-[#1b1a1a]">
                  <span className="h-2.5 w-2.5 rounded-full bg-[#6d8d66]" />
                  {member}
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-[22px] border border-[#2a2928] bg-[#f9f5f1] p-4">
            <div className="mb-4 text-[0.72rem] font-medium uppercase tracking-[0.18em] text-[#625d5a]">
              Recipe of the week
            </div>
            <div className="overflow-hidden rounded-[18px] bg-[#ddd4cb]">
              <div
                className="h-[180px] w-full bg-cover bg-center"
                style={{
                  backgroundImage:
                    'url("https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=80")',
                }}
              />
            </div>
            <div className="mt-4 text-[1.1rem] font-medium text-[#1b1a1a]">Rustic Olive Focaccia</div>
            <div className="mt-1 text-sm text-[#615d5a]">By Chef Pierre • 45 min prep</div>
          </div>
        </aside>
      </div>
    </div>
  )
}

