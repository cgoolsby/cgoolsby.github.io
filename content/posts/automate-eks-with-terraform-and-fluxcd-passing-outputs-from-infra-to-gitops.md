+++
title = "Automate EKS with Terraform and FluxCD: Passing Outputs from Infra to GitOps"
description = ""
date = 2025-05-11
author = {name = "Curtis Goolsby", email = "curtis@kubepros.dev"}
tags = []
draft = true
+++

When managing Kubernetes infrastructure at scale, it's common to use [Terraform](https://www.terraform.io/) to provision the cluster and [FluxCD](https://fluxcd.io/) (or ArgoCD) to deploy workloads onto it. However, a frequent challenge arises: **how do you pass dynamic values—like EKS endpoints or IAM ARNs—from Terraform into your GitOps configuration?**

In this post, we'll walk through a practical and production-ready method to bridge that gap using a **ConfigMap and FluxCD's `postBuild.substituteFrom`** capability.

---

## Why This Pattern Matters

Certain values in an AWS EKS cluster—like:

- `module.eks.cluster_endpoint`
- `aws_efs_file_system.efs_dns_name`
- `data.aws_caller_identity.current.account_id`
- `aws_iam_role.ebs_csi_role.arn`

…are not known until **after** Terraform runs. But if you're using FluxCD or ArgoCD to manage Kubernetes components, you need these values available **at GitOps runtime**.

Our solution: output the values from Terraform into a `ConfigMap` inside the `flux-system` namespace, then reference that `ConfigMap` in FluxCD using a `substituteFrom` block.

---

## Step 1: Bootstrap the Flux Namespace

Terraform should not directly manage the lifecycle of the `flux-system` namespace, especially if Flux is self-managing. To avoid `terraform destroy` side effects, use a `null_resource` to create the namespace imperatively:

```hcl
resource "null_resource" "flux_system_namespace" {
  provisioner "local-exec" {
    command = "kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -"
  }

  triggers = {
    cluster_endpoint = module.eks.cluster_endpoint
  }

  depends_on = [module.eks]
}

data "kubernetes_namespace" "flux_system" {
  metadata {
    name = "flux-system"
  }

  depends_on = [null_resource.flux_system_namespace]
}
```

---

## Step 2: Export Terraform Outputs into a ConfigMap

We now create a `ConfigMap` to expose useful Terraform output values to FluxCD.

```hcl
resource "kubernetes_config_map" "terraform_outputs" {
  metadata {
    name      = "terraform-outputs"
    namespace = "flux-system"
  }

  data = {
    AWS_ACCOUNT_ID     = data.aws_caller_identity.current.account_id
    EBS_CSI_ROLE_ARN   = aws_iam_role.ebs_csi_role.arn
    CLUSTER_NAME       = var.cluster_name
    CLUSTER_ENDPOINT   = module.eks.cluster_endpoint
  }

  lifecycle {
    ignore_changes = [
      metadata[0].annotations,
      metadata[0].labels,
      metadata[0].generation,
      metadata[0].resource_version
    ]
    prevent_destroy = false
  }

  depends_on = [
    module.eks,
    data.kubernetes_namespace.flux_system
  ]
}
```

This approach allows your Terraform to dynamically feed values into the GitOps pipeline via Kubernetes-native resources.

---

## Step 3: Consume the ConfigMap with FluxCD

FluxCD supports `substituteFrom` in its `Kustomization` manifests. This lets you reference the `ConfigMap` created by Terraform:

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: aws-ebs-csi
  namespace: flux-system
spec:
  interval: 10m
  path: ./infra/base/aws-ebs-csi
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  dependsOn:
    - name: flux-system
  postBuild:
    substituteFrom:
      - kind: ConfigMap
        name: terraform-outputs
```

Inside your Kustomize manifests (`infra/base/aws-ebs-csi/`), use variable substitution like `${EBS_CSI_ROLE_ARN}` to inject these dynamic values.

---

## Summary

This integration pattern lets you:

- Keep Terraform focused on infrastructure provisioning.
- Use FluxCD/ArgoCD to manage in-cluster components declaratively.
- Avoid hardcoding account- or cluster-specific values in your GitOps repos.
- Scale across environments using dynamic and reproducible workflows.

---

## Related Reading

- [FluxCD Kustomization Documentation](https://fluxcd.io/flux/components/kustomize/kustomization/)
- [Terraform Kubernetes Provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest)
- [Best Practices for GitOps on EKS](https://aws.amazon.com/blogs/opensource/gitops-flux-eks/)
