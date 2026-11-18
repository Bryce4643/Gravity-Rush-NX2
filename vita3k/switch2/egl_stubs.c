// Switch 2: this build renders with Vulkan (OunceVK) only. The Switch frame
// host still names the EGL functions its OpenGL path uses; these definitions
// make every EGL call fail, so selecting OpenGL reports an error instead of
// linking a second graphics driver into the program.
// SPDX-License-Identifier: GPL-2.0-or-later

#include <EGL/egl.h>

#include <stddef.h>

EGLDisplay eglGetDisplay(EGLNativeDisplayType display_id) {
    (void)display_id;
    return EGL_NO_DISPLAY;
}

EGLBoolean eglInitialize(EGLDisplay dpy, EGLint *major, EGLint *minor) {
    (void)dpy;
    (void)major;
    (void)minor;
    return EGL_FALSE;
}

EGLint eglGetError(void) {
    return EGL_NOT_INITIALIZED;
}

EGLBoolean eglBindAPI(EGLenum api) {
    (void)api;
    return EGL_FALSE;
}

EGLBoolean eglChooseConfig(EGLDisplay dpy, const EGLint *attrib_list, EGLConfig *configs, EGLint config_size, EGLint *num_config) {
    (void)dpy;
    (void)attrib_list;
    (void)configs;
    (void)config_size;
    if (num_config)
        *num_config = 0;
    return EGL_FALSE;
}

EGLSurface eglCreateWindowSurface(EGLDisplay dpy, EGLConfig config, EGLNativeWindowType win, const EGLint *attrib_list) {
    (void)dpy;
    (void)config;
    (void)win;
    (void)attrib_list;
    return EGL_NO_SURFACE;
}

EGLContext eglCreateContext(EGLDisplay dpy, EGLConfig config, EGLContext share_context, const EGLint *attrib_list) {
    (void)dpy;
    (void)config;
    (void)share_context;
    (void)attrib_list;
    return EGL_NO_CONTEXT;
}

EGLBoolean eglMakeCurrent(EGLDisplay dpy, EGLSurface draw, EGLSurface read, EGLContext ctx) {
    (void)dpy;
    (void)draw;
    (void)read;
    (void)ctx;
    return EGL_FALSE;
}

EGLContext eglGetCurrentContext(void) {
    return EGL_NO_CONTEXT;
}

EGLBoolean eglSwapBuffers(EGLDisplay dpy, EGLSurface surface) {
    (void)dpy;
    (void)surface;
    return EGL_FALSE;
}

EGLBoolean eglSwapInterval(EGLDisplay dpy, EGLint interval) {
    (void)dpy;
    (void)interval;
    return EGL_FALSE;
}

EGLBoolean eglDestroyContext(EGLDisplay dpy, EGLContext ctx) {
    (void)dpy;
    (void)ctx;
    return EGL_FALSE;
}

EGLBoolean eglDestroySurface(EGLDisplay dpy, EGLSurface surface) {
    (void)dpy;
    (void)surface;
    return EGL_FALSE;
}

EGLBoolean eglTerminate(EGLDisplay dpy) {
    (void)dpy;
    return EGL_FALSE;
}

EGLBoolean eglReleaseThread(void) {
    return EGL_TRUE;
}

__eglMustCastToProperFunctionPointerType eglGetProcAddress(const char *procname) {
    (void)procname;
    return NULL;
}
