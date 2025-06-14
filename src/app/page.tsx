import { Metadata } from "next"
import Link from "next/link"
import { Button } from "@/components/ui/button"
import { ArrowRight, Building2, Users, Briefcase, Target } from "lucide-react"

export const metadata: Metadata = {
  title: "VentureLink - Plateforme de Networking pour Entrepreneurs",
  description: "Connectez-vous avec d'autres entrepreneurs, trouvez des opportunités de collaboration et développez votre réseau professionnel.",
}

export default function HomePage() {
  return (
    <div className="flex flex-col min-h-screen">
      {/* Hero Section */}
      <section className="relative py-20 md:py-32 bg-gradient-to-b from-background to-muted">
        <div className="container px-4 md:px-6">
          <div className="flex flex-col items-center space-y-8 text-center">
            <div className="space-y-4">
              <h1 className="text-4xl md:text-6xl font-bold tracking-tighter">
                Connectez-vous avec des{" "}
                <span className="text-primary">entrepreneurs</span>{" "}
                qui partagent votre vision
              </h1>
              <p className="mx-auto max-w-[700px] text-muted-foreground md:text-xl">
                Rejoignez une communauté dynamique d'entrepreneurs, trouvez des opportunités de collaboration et développez votre réseau professionnel.
              </p>
            </div>
            <div className="flex flex-col sm:flex-row gap-4">
              <Button asChild size="lg">
                <Link href="/register">
                  Commencer gratuitement
                  <ArrowRight className="ml-2 h-4 w-4" />
                </Link>
              </Button>
              <Button variant="outline" size="lg" asChild>
                <Link href="/about">
                  En savoir plus
                </Link>
              </Button>
            </div>
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section className="py-20 bg-background">
        <div className="container px-4 md:px-6">
          <div className="grid gap-12 md:grid-cols-2 lg:grid-cols-4">
            <div className="flex flex-col items-center space-y-4 text-center">
              <div className="p-4 bg-primary/10 rounded-full">
                <Users className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-xl font-bold">Réseau Professionnel</h3>
              <p className="text-muted-foreground">
                Connectez-vous avec des entrepreneurs partageant vos intérêts et objectifs.
              </p>
            </div>
            <div className="flex flex-col items-center space-y-4 text-center">
              <div className="p-4 bg-primary/10 rounded-full">
                <Building2 className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-xl font-bold">Opportunités de Collaboration</h3>
              <p className="text-muted-foreground">
                Découvrez des projets et des partenariats qui correspondent à vos ambitions.
              </p>
            </div>
            <div className="flex flex-col items-center space-y-4 text-center">
              <div className="p-4 bg-primary/10 rounded-full">
                <Briefcase className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-xl font-bold">Ressources Entrepreneuriales</h3>
              <p className="text-muted-foreground">
                Accédez à des outils et des conseils pour développer votre entreprise.
              </p>
            </div>
            <div className="flex flex-col items-center space-y-4 text-center">
              <div className="p-4 bg-primary/10 rounded-full">
                <Target className="h-6 w-6 text-primary" />
              </div>
              <h3 className="text-xl font-bold">Objectifs Communs</h3>
              <p className="text-muted-foreground">
                Trouvez des entrepreneurs qui partagent vos valeurs et votre vision.
              </p>
            </div>
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 bg-muted">
        <div className="container px-4 md:px-6">
          <div className="flex flex-col items-center space-y-8 text-center">
            <div className="space-y-4">
              <h2 className="text-3xl md:text-4xl font-bold tracking-tighter">
                Prêt à rejoindre notre communauté ?
              </h2>
              <p className="mx-auto max-w-[600px] text-muted-foreground md:text-xl">
                Créez votre profil gratuitement et commencez à développer votre réseau professionnel dès aujourd'hui.
              </p>
            </div>
            <Button asChild size="lg">
              <Link href="/register">
                Créer un compte
                <ArrowRight className="ml-2 h-4 w-4" />
              </Link>
            </Button>
          </div>
        </div>
      </section>
    </div>
  )
} 