<template>
    <div>
        <h1 class="title">About Me</h1>
        <div>
            <h3 class="font-bold text-2xl">Hey there, I'm Winner Edwin – <b class="theme">a Web Developer</b></h3>
            <p class="leading-normal">With a knack for weaving innovation and elegance into digital experiences. Over 3 years, I've mastered TailwindCSS for crafting visually alluring websites, and seamlessly integrated Vue and React to bring projects like AudHub to life. My focus? Fast-loading, engaging interfaces, often fueled by the magic of Firebase. Passionate about Vue, JavaScript, and efficient design, I'm on a perpetual quest for web excellence. Let's collaborate and transform your ideas into exceptional digital marvels.</p>
            <div class="lg:grid lg:grid-cols-2 lg:gap-3">
                <div class="flex flex-col gap-5">
                    <table>
                        <tbody>
                            <tr>
                                <td><b>Birthday</b> 26th June 2007</td>
                                <td><b>Age</b> 16</td>
                            </tr>
                            <tr>
                                <td><b>Website</b> <a href="https://mikelneonedwin.vercel.app">mikelneonedwin.vercel.app</a></td>
                                <td><b>Email</b> <a href="mailto:mynameiswinneredwin@gmail.com">mynameiswinneredwin@gmail.com</a></td>
                            </tr>
                            <tr>
                                <td><b>Degree</b> CS</td>
                                <td><b>Phone</b> <a href="tel:2348076488738">08076488738</a></td>
                            </tr>
                            <tr>
                                <td><b>City</b> Uyo</td>
                                <td><b>Freelance</b> Available!</td>
                            </tr>
                        </tbody>
                    </table>
                    <div class="flex gap-4 items-center">
                        <button class="btn">Download CV</button>
                        <button class="btn">Hire Me</button>
                    </div>
                </div>
            </div>
            <div class="mt-2">
                <h3 class="font-bold text-2xl">Skills</h3>
                <div class="skills">
                    <button>HTML</button><button>CSS</button><button>JavaScript</button><button>TailwindCSS</button><button>jQuery</button><button>Vue.js</button><button>React.js</button><button>Nuxt.js</button><button>Firebase</button><button>Vercel</button><button>GitHub</button><button>Node.js</button><button>Express.js</button>
                </div>
            </div>
            <div class="mt-2">
                <h2 class="text-2xl font-bold">Experience</h2>
                <div class="border-l-4 border-[--theme] ml-1 py-4 space-y-14">
                    <div>
                        <div class="dot"></div>
                        <div class="pl-8">
                            <span class="timeline-date">2023-07-16 - 2023-08-15</span>
                            <h3 class=timeline-title>30 Days of code with VickyJay</h3>
                            <p class="text-gray-400">During the summer of 2023, I undertook an exhilarating journey to enhance my web development skills through an intensive 30-day challenge. The challenge required me to conceptualize, design, and develop a unique web project each day, pushing my creative boundaries and technical expertise to the limit.</p>
                        </div>
                    </div>
                    <div>
                        <div class="dot"></div>
                        <div class="pl-8">
                            <span class="timeline-date">2022-09-00 - Ongoing</span>
                            <h3 class="timeline-title">AudHub - Elevating African Upcoming Artists</h3>
                            <p class="text-gray-400 leading-relaxed">
                                Initiated in September 2022, AudHub is an ongoing initiative aimed at empowering emerging African artists through a dedicated music streaming platform. AudHub provides uninterrupted music streaming, giving voice to budding artists without interruptions. The platform showcases top tracks through an engaging chart, spotlighting artists based on audience engagement. AudHub offers artists the ability to directly upload, manage, and share their music, putting creative control in their hands.
                                <br><br>As AudHub remains in development:
                                <br>We are actively fostering a dynamic community of music enthusiasts and artists. Our commitment continues as we expand the platform's scope, providing invaluable support to artists on their creative journey.
                            </p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<style type="text/tailwindcss">
    @tailwind components;
    td {
      @apply border-b w-full flex sm:flex-col sm:items-start sm:truncate items-center py-2 gap-1 border-b-[#444];
    }
    tr {
        @apply grid grid-cols-2 gap-2 items-center w-full;
    }
    td b::after {
        content: ":"
    }
    td b {
        @apply font-semibold;
    }
    .skills>button {
        @apply mr-2 mt-2 inline-flex items-center justify-center py-1 px-4 bg-[#00DC82] text-white font-medium rounded-md text-sm;
    }
    @layer components {
        .dot {
            @apply absolute -translate-x-3.5 bg-[#00DC82] h-6 w-6 rounded-full border-4 border-gray-200;
        }
        .timeline-date {
                @apply text-xs font-bold opacity-70 tracking-widest text-white;
            }
        .timeline-title {
            @apply text-3xl text-gray-200 font-semibold tracking-wide mb-2
        }
    }
    p b {
        @apply font-normal text-gray-200;
    }
</style>