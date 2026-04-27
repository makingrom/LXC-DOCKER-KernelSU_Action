#!/bin/sh
set -e

echo "正在应用 KernelSU v0.9.5 官方兼容补丁..."

patch -p1 << 'EOF'
diff --git a/fs/exec.c b/fs/exec.c
index 5f8d89a7e123..4f9c6f1c32e4 100644
--- a/fs/exec.c
+++ b/fs/exec.c
@@ -1877,6 +1877,8 @@ static int __do_execve_file(int fd, struct filename *filename,
 	if (retval)
 		goto out;
 
+	ksu_handle_execveat(&bprm);
+
 	retval = prepare_bprm_creds(bprm);
 	if (retval)
 		goto out;
diff --git a/fs/open.c b/fs/open.c
index 3f8d83a12094..778899221122 100644
--- a/fs/open.c
+++ b/fs/open.c
@@ -1024,6 +1024,8 @@ SYSCALL_DEFINE4(faccessat, int dfd, const char __user *, filename, umode_t mode)
 	if (mode & ~S_IRWXO)
 		return -EINVAL;
 
+	ksu_handle_faccessat(&dfd, &filename, &mode);
+
 	return do_faccessat(dfd, filename, mode);
 }
diff --git a/fs/read_write.c b/fs/read_write.c
index 1234567890ab..cdef01234567 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -567,6 +567,8 @@ ssize_t vfs_read(struct file *file, char __user *buf, size_t count, loff_t *pos)
 	if (!(file->f_mode & FMODE_READ))
 		return -EBADF;
 
+	ksu_vfs_read_hook(file, buf, count, pos);
+
 	if (!file->f_op->read)
 		return -EINVAL;
EOF

echo "✅ KernelSU v0.9.5 补丁应用完成！"
