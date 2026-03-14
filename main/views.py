from django.shortcuts import render, redirect, get_object_or_404
from django.contrib import messages
from .models import Profile, Skill, Project, Experience, Education, Service, Testimonial, Certificate, Contact

def get_profile():
    return Profile.objects.first()

def home(request):
    profile = get_profile()
    featured_projects = Project.objects.filter(featured=True)[:3]
    services = Service.objects.all()[:6]
    skills = Skill.objects.all()[:10]
    testimonials = Testimonial.objects.filter(featured=True)[:4]
    experiences = Experience.objects.all()
    certificates = Certificate.objects.all()
    is_fresher = not experiences.exists()
    return render(request, 'main/home.html', {
        'profile': profile,
        'featured_projects': featured_projects,
        'services': services,
        'skills': skills,
        'testimonials': testimonials,
        'experiences': experiences,
        'certificates': certificates,
        'is_fresher': is_fresher,
        'fresher_points': ['Strong academics', 'Hands-on projects', 'Quick learner', 'Latest tech trends', 'Open to mentorship', 'Team player'],
    })

def about(request):
    profile = get_profile()
    experiences = Experience.objects.all()
    educations = Education.objects.all()
    certificates = Certificate.objects.all()
    is_fresher = not experiences.exists()
    return render(request, 'main/about.html', {
        'profile': profile,
        'experiences': experiences,
        'educations': educations,
        'certificates': certificates,
        'is_fresher': is_fresher,
        'fresher_points_full': ['Strong CS fundamentals', 'Self-taught & curious', 'Built multiple real-world projects', 'Open-source contributor mindset', 'Adapts fast to new tech', 'Team-oriented & collaborative', 'Deadline-driven approach', 'Passionate about clean code'],
    })

def skills(request):
    profile = get_profile()
    skill_categories = {}
    for skill in Skill.objects.all():
        cat = skill.get_category_display()
        if cat not in skill_categories:
            skill_categories[cat] = []
        skill_categories[cat].append(skill)
    return render(request, 'main/skills.html', {
        'profile': profile,
        'skill_categories': skill_categories,
    })

def projects(request):
    profile = get_profile()
    all_projects = Project.objects.all()
    filter_status = request.GET.get('filter', 'all')
    if filter_status != 'all':
        all_projects = all_projects.filter(status=filter_status)
    return render(request, 'main/projects.html', {
        'profile': profile,
        'projects': all_projects,
        'filter_status': filter_status,
    })

def project_detail(request, pk):
    profile = get_profile()
    project = get_object_or_404(Project, pk=pk)
    related = Project.objects.exclude(pk=pk).filter(status=project.status)[:3]
    return render(request, 'main/project_detail.html', {
        'profile': profile,
        'project': project,
        'related': related,
    })

def experience(request):
    profile = get_profile()
    experiences = Experience.objects.all()
    educations = Education.objects.all()
    is_fresher = not experiences.exists()
    return render(request, 'main/experience.html', {
        'profile': profile,
        'experiences': experiences,
        'educations': educations,
        'is_fresher': is_fresher,
        'fresher_points_full': ['Strong CS fundamentals', 'Self-taught & curious', 'Built multiple real-world projects', 'Open-source contributor mindset', 'Adapts fast to new tech', 'Team-oriented & collaborative', 'Deadline-driven approach', 'Passionate about clean code'],
    })

def contact(request):
    profile = get_profile()
    if request.method == 'POST':
        name = request.POST.get('name')
        email = request.POST.get('email')
        subject = request.POST.get('subject')
        message = request.POST.get('message')
        if name and email and subject and message:
            Contact.objects.create(name=name, email=email, subject=subject, message=message)
            messages.success(request, 'Your message has been sent successfully! I will get back to you soon.')
            return redirect('contact')
        else:
            messages.error(request, 'Please fill in all fields.')
    return render(request, 'main/contact.html', {'profile': profile})
